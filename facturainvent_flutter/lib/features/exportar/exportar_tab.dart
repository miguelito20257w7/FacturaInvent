import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_state.dart';
import '../../data/firestore/empresa_repository.dart';
import '../../data/firestore/producto_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/empresa.dart';
import '../../models/producto.dart';
import '../../models/producto_import.dart';
import '../../services/xml_factura_parser.dart';
import '../../services/xlsx_exporter.dart';
import '../producto/preview_producto.dart';

class ExportarTab extends ConsumerStatefulWidget {
  const ExportarTab({super.key});

  @override
  ConsumerState<ExportarTab> createState() => _ExportarTabState();
}

class _ExportarTabState extends ConsumerState<ExportarTab> {
  final List<ProductoImport> _productos = [];
  // ignore: unused_field
  Empresa? _empresa;
  File? _generated;
  String? _error;
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget body;
    if (_generated != null) {
      body = _exitoView(t, _generated!);
    } else if (_productos.isEmpty) {
      body = _vaciaView(t);
    } else {
      body = _listaView(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_productos.isEmpty && _generated == null
            ? t.newXlsxFile
            : _generated != null
                ? t.success
                : t.reviewProducts),
        leading: (_productos.isEmpty && _generated == null)
            ? null
            : TextButton(
                onPressed: _reiniciar,
                child: Text(t.cancel),
              ),
        leadingWidth: 100,
        actions: [
          if (_productos.isNotEmpty && _generated == null)
            TextButton(
              onPressed: _generating ? null : _confirmarYExportar,
              child: Text(t.confirm),
            ),
          if (_generated != null)
            TextButton(onPressed: _reiniciar, child: Text(t.startOver)),
        ],
      ),
      body: body,
    );
  }

  Widget _vaciaView(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_outlined,
              size: 100, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(t.firstAddXmlFile),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _pickXml,
            icon: const Icon(Icons.upload_file),
            label: Text(t.addXml),
          ),
          if (_error != null) ...[
            const SizedBox(height: 24),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    );
  }

  Widget _listaView(AppLocalizations t) {
    return ListView.separated(
      itemCount: _productos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = _productos[i];
        return ListTile(
          title: Text(p.nombre),
          subtitle:
              Text(p.codigo, style: Theme.of(context).textTheme.bodySmall),
          onTap: () async {
            final updated = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PreviewProducto(
                  producto: p,
                  modoExcelPreview: true,
                  onEliminar: () =>
                      setState(() => _productos.removeWhere((x) => x.id == p.id)),
                ),
              ),
            );
            if (updated is ProductoImport) {
              setState(() => _productos[i] = updated);
            }
          },
        );
      },
    );
  }

  Widget _exitoView(AppLocalizations t, File file) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle,
              size: 100, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(t.excelGenerated,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(t.fileReadyToExport),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await Share.shareXFiles(
                [XFile(file.path)],
                subject: 'productos.xlsx',
              );
            },
            icon: const Icon(Icons.share),
            label: Text(t.shareExcel),
          ),
        ],
      ),
    );
  }

  Future<void> _pickXml() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final file = File(result.files.single.path!);
      final contenido = await file.readAsString();
      final parser = XMLFacturaParser();
      final parsed = parser.parseContenidoXML(contenido);
      if (parsed == null) {
        setState(() =>
            _error = 'El archivo XML no tiene el formato esperado.');
        return;
      }

      final empresaRepo = ref.read(empresaRepositoryProvider);
      final empresa = await empresaRepo.findByNit(parsed.nit);
      final productosEmpresa = empresa?.id != null
          ? await ref
              .read(productoRepositoryProvider)
              .getByEmpresa(empresa!.id!)
          : <Producto>[];

      final lista = parsed.productos.map((p) {
        final encontrado = _buscarProducto(p, productosEmpresa);
        return ProductoImport.create(
          codigo: p.codigo,
          codigoBarras: encontrado?.codigoBarras ?? p.codigoBarras,
          nombre: p.nombre,
          cantidad: p.cantidad,
          precioSinIVA: p.precioSinIVA,
          vieneEnPaquetes: encontrado?.vieneEnPaquetes ?? false,
          cantidadPaquetes: encontrado?.cantidadPaquetes ?? 1,
          codigoBarrasAutomatico:
              encontrado?.codigoDeBarrasAutomatico ?? false,
          codigoInterno: encontrado?.codigoInterno ?? '',
          tieneDescuento: p.tieneDescuento,
          porcentajeDescuento: p.porcentajeDescuento,
          empresa: empresa,
        );
      }).toList();

      setState(() {
        _empresa = empresa;
        _productos
          ..clear()
          ..addAll(lista);
      });
    } catch (e) {
      setState(() => _error = 'No se pudo leer el archivo: $e');
    }
  }

  Producto? _buscarProducto(
    XMLProductoData data,
    List<Producto> productosEmpresa,
  ) {
    if (data.codigo.isNotEmpty) {
      final p = productosEmpresa
          .firstWhereOrNull((e) => e.codigoFactura == data.codigo);
      if (p != null) return p;
    }
    if (data.codigoBarras.isNotEmpty) {
      final p = productosEmpresa
          .firstWhereOrNull((e) => e.codigoBarras == data.codigoBarras);
      if (p != null) return p;
    }
    if (data.nombre.isNotEmpty) {
      final p = productosEmpresa.firstWhereOrNull((e) => e.nombre == data.nombre);
      if (p != null) return p;
    }
    return null;
  }

  Future<void> _confirmarYExportar() async {
    setState(() => _generating = true);
    final t = AppLocalizations.of(context);

    try {
      // Actualizar cantidades en Firestore (equivalente a confirmarYExportar)
      final productoRepo = ref.read(productoRepositoryProvider);
      for (final p in _productos) {
        if (p.empresa?.id == null) continue;
        final cantidadInt = (double.tryParse(p.cantidad) ?? 0).toInt();
        final totalPaquetes = cantidadInt * p.cantidadPaquetes;
        final existentes =
            await productoRepo.getByEmpresa(p.empresa!.id!);
        final existente = existentes
            .firstWhereOrNull((e) => e.codigoFactura == p.codigo);
        if (existente != null) {
          final precio = ((double.tryParse(p.precioSinIVA.replaceAll(',', '.')) ?? 0)
                  .toInt() /
              (p.cantidadPaquetes > 0 ? p.cantidadPaquetes : 1))
              .toInt();
          await productoRepo.update(existente.copyWith(
            cantidadProductos: totalPaquetes,
            precio: precio,
          ));
        }
      }

      final file = await exportarExcel(_productos);
      if (file == null) {
        setState(() {
          _error = 'No se pudo generar el archivo Excel.';
          _generating = false;
        });
        return;
      }
      setState(() {
        _generated = file;
        _generating = false;
      });
    } catch (e) {
      setState(() {
        _error = '${t.error}: $e';
        _generating = false;
      });
    }
  }

  void _reiniciar() {
    setState(() {
      _productos.clear();
      _empresa = null;
      _generated = null;
      _error = null;
    });
    ref.read(selectedTabProvider.notifier).set(0);
  }
}
