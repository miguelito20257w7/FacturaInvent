import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/producto.dart';

class ProductoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProductoRepository(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    return _firestore.collection('users').doc(uid).collection('productos');
  }

  Stream<List<Producto>> watchAll() {
    return _col().snapshots().map(
          (snap) => snap.docs
              .map((d) => Producto.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Stream<List<Producto>> watchByEmpresa(String empresaId) {
    return _col()
        .where('empresaId', isEqualTo: empresaId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Producto.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Future<List<Producto>> getByEmpresa(String empresaId) async {
    final snap =
        await _col().where('empresaId', isEqualTo: empresaId).get();
    return snap.docs
        .map((d) => Producto.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Producto> create(Producto producto) async {
    final data = producto.toJson()..remove('id');
    final doc = await _col().add(data);
    return producto.copyWith(id: doc.id);
  }

  Future<void> createBatch(List<Producto> productos) async {
    final batch = _firestore.batch();
    for (final p in productos) {
      final data = p.toJson()..remove('id');
      batch.set(_col().doc(), data);
    }
    await batch.commit();
  }

  Future<void> update(Producto producto) async {
    if (producto.id == null) {
      throw ArgumentError('Producto sin id no se puede actualizar');
    }
    final data = producto.toJson()..remove('id');
    await _col().doc(producto.id).update(data);
  }

  Future<void> delete(String productoId) async {
    await _col().doc(productoId).delete();
  }
}

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final productosStreamProvider = StreamProvider<List<Producto>>((ref) {
  return ref.watch(productoRepositoryProvider).watchAll();
});

final productosPorEmpresaProvider =
    StreamProvider.family<List<Producto>, String>((ref, empresaId) {
  return ref.watch(productoRepositoryProvider).watchByEmpresa(empresaId);
});
