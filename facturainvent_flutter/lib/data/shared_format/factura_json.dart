import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/empresa.dart';
import '../../models/producto.dart';
import '../firestore/empresa_repository.dart';
import '../firestore/producto_repository.dart';

/// Versión actual del formato JSON compartido.
/// Debe coincidir con `FacturaJSONVersionActual` en
/// `FacturaInvent/FacturaJSONFormat.swift`.
const int formatVersionActual = 1;

/// Formato JSON compartido entre la app Swift y la app Flutter.
/// Versión 1.
///
/// {
///   "version": 1,
///   "exportedAt": "ISO8601",
///   "empresas": [
///     { "nit": "...", "nombre": "...",
///       "productos": [ { ... } ] }
///   ]
/// }
class FacturaJsonExporter {
  final EmpresaRepository empresaRepo;
  final ProductoRepository productoRepo;

  FacturaJsonExporter(this.empresaRepo, this.productoRepo);

  Future<String> export() async {
    final empresas = await empresaRepo.watchAll().first;
    final productos = await productoRepo.watchAll().first;

    final productosPorEmpresa = <String, List<Producto>>{};
    for (final p in productos) {
      if (p.empresaId == null) continue;
      productosPorEmpresa.putIfAbsent(p.empresaId!, () => []).add(p);
    }

    final data = {
      'version': formatVersionActual,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'empresas': empresas.map((e) {
        final prods = productosPorEmpresa[e.id] ?? const <Producto>[];
        return {
          'nit': e.nit,
          'nombre': e.nombre,
          'productos': prods
              .map((p) => {
                    'codigoFactura': p.codigoFactura,
                    'codigoBarras': p.codigoBarras,
                    'nombre': p.nombre,
                    'codigoDeBarrasAutomatico': p.codigoDeBarrasAutomatico,
                    'cantidadProductos': p.cantidadProductos,
                    'precio': p.precio,
                    'precioDividido': p.precioDividido,
                    'vieneEnPaquetes': p.vieneEnPaquetes,
                    'cantidadPaquetes': p.cantidadPaquetes,
                    'codigoInterno': p.codigoInterno,
                    'tieneDescuento': p.tieneDescuento,
                  })
              .toList(),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<File> exportToFile(File file) async {
    final json = await export();
    await file.writeAsString(json);
    return file;
  }
}

class FacturaJsonImporter {
  final EmpresaRepository empresaRepo;
  final ProductoRepository productoRepo;

  FacturaJsonImporter(this.empresaRepo, this.productoRepo);

  /// Importa el JSON reemplazando todos los datos del usuario.
  /// (Equivalente al `ImportarBaseDeDatos.swift` que también borra y reinserta.)
  ///
  /// Acepta cualquier versión `<= formatVersionActual` para mantener compat
  /// con la app iOS, que sigue el mismo criterio.
  Future<({int empresasCreadas, int productosCreados})> importReplaceAll(
    String json,
  ) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final version = data['version'];
    if (version is! int || version > formatVersionActual || version < 1) {
      throw FormatException('Versión de formato no soportada: $version');
    }

    await _wipeAllUserData();

    int empresasCount = 0;
    int productosCount = 0;
    final empresasJson = (data['empresas'] as List).cast<Map<String, dynamic>>();
    for (final empresaData in empresasJson) {
      final empresa = await empresaRepo.create(Empresa(
        nombre: (empresaData['nombre'] as String?) ?? '',
        nit: (empresaData['nit'] as String?) ?? '',
      ));
      empresasCount += 1;

      final productosJson =
          ((empresaData['productos'] as List?) ?? const [])
              .cast<Map<String, dynamic>>();
      final productos = productosJson
          .map((p) => Producto(
                empresaId: empresa.id,
                codigoFactura: (p['codigoFactura'] as String?) ?? '',
                codigoBarras: (p['codigoBarras'] as String?) ?? '',
                nombre: (p['nombre'] as String?) ?? '',
                codigoDeBarrasAutomatico:
                    (p['codigoDeBarrasAutomatico'] as bool?) ?? false,
                cantidadProductos: (p['cantidadProductos'] as int?) ?? 0,
                precio: (p['precio'] as int?) ?? 0,
                precioDividido: (p['precioDividido'] as int?) ?? 1,
                vieneEnPaquetes: (p['vieneEnPaquetes'] as bool?) ?? false,
                cantidadPaquetes: (p['cantidadPaquetes'] as int?) ?? 1,
                codigoInterno: (p['codigoInterno'] as String?) ?? '',
                tieneDescuento: (p['tieneDescuento'] as bool?) ?? false,
              ))
          .toList();

      if (productos.isNotEmpty) {
        await productoRepo.createBatch(productos);
      }
      productosCount += productos.length;
    }

    return (
      empresasCreadas: empresasCount,
      productosCreados: productosCount,
    );
  }

  /// Borra todas las empresas y productos del usuario actual.
  /// Incluye productos huérfanos (sin empresaId o con empresaId que ya no existe).
  /// Se hace en batches de 400 documentos para respetar el límite de Firestore (500).
  Future<void> _wipeAllUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(uid);

    Future<void> deleteAll(CollectionReference<Map<String, dynamic>> col) async {
      const chunkSize = 400;
      while (true) {
        final snap = await col.limit(chunkSize).get();
        if (snap.docs.isEmpty) break;
        final batch = firestore.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
        if (snap.docs.length < chunkSize) break;
      }
    }

    await deleteAll(userDoc.collection('productos'));
    await deleteAll(userDoc.collection('empresas'));
  }
}

final facturaJsonExporterProvider = Provider<FacturaJsonExporter>((ref) {
  return FacturaJsonExporter(
    ref.watch(empresaRepositoryProvider),
    ref.watch(productoRepositoryProvider),
  );
});

final facturaJsonImporterProvider = Provider<FacturaJsonImporter>((ref) {
  return FacturaJsonImporter(
    ref.watch(empresaRepositoryProvider),
    ref.watch(productoRepositoryProvider),
  );
});
