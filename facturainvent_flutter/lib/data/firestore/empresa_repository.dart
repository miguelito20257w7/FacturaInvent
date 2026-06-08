import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/empresa.dart';

/// Acceso a la colección `users/{uid}/empresas` en Firestore.
/// Las operaciones de borrado en cascada (empresa → productos) se hacen aquí.
class EmpresaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmpresaRepository(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> _empresasCol() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    return _firestore.collection('users').doc(uid).collection('empresas');
  }

  CollectionReference<Map<String, dynamic>> _productosCol() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    return _firestore.collection('users').doc(uid).collection('productos');
  }

  Stream<List<Empresa>> watchAll() {
    return _empresasCol().orderBy('nombre').snapshots().map(
          (snap) => snap.docs
              .map((d) => Empresa.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Future<Empresa?> findByNit(String nit) async {
    final result =
        await _empresasCol().where('nit', isEqualTo: nit).limit(1).get();
    if (result.docs.isEmpty) return null;
    final d = result.docs.first;
    return Empresa.fromJson({...d.data(), 'id': d.id});
  }

  Future<Empresa> create(Empresa empresa) async {
    final doc = await _empresasCol().add(empresa.copyWith(id: null).toJson()
      ..remove('id'));
    return empresa.copyWith(id: doc.id);
  }

  Future<void> update(Empresa empresa) async {
    if (empresa.id == null) {
      throw ArgumentError('Empresa sin id no se puede actualizar');
    }
    final data = empresa.toJson()..remove('id');
    await _empresasCol().doc(empresa.id).update(data);
  }

  Future<void> delete(String empresaId) async {
    final batch = _firestore.batch();
    final productos = await _productosCol()
        .where('empresaId', isEqualTo: empresaId)
        .get();
    for (final p in productos.docs) {
      batch.delete(p.reference);
    }
    batch.delete(_empresasCol().doc(empresaId));
    await batch.commit();
  }

  Future<void> rename(String empresaId, String nuevoNombre) async {
    await _empresasCol().doc(empresaId).update({'nombre': nuevoNombre});
  }
}

final empresaRepositoryProvider = Provider<EmpresaRepository>((ref) {
  return EmpresaRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final empresasStreamProvider = StreamProvider<List<Empresa>>((ref) {
  return ref.watch(empresaRepositoryProvider).watchAll();
});
