import 'package:uuid/uuid.dart';

import 'producto.dart';
import 'producto_import.dart';

class ProductoConflicto {
  final String id;
  final Producto productoEnDB;
  final ProductoImport datosNuevos;

  ProductoConflicto({
    String? id,
    required this.productoEnDB,
    required this.datosNuevos,
  }) : id = id ?? const Uuid().v4();
}
