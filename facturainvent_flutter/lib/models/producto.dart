import 'package:freezed_annotation/freezed_annotation.dart';

part 'producto.freezed.dart';
part 'producto.g.dart';

@freezed
class Producto with _$Producto {
  const factory Producto({
    String? id,
    String? empresaId,
    @Default('') String codigoFactura,
    @Default('') String codigoBarras,
    @Default('') String nombre,
    @Default(false) bool codigoDeBarrasAutomatico,
    @Default(0) int cantidadProductos,
    @Default(0) int precio,
    @Default(1) int precioDividido,
    @Default(false) bool vieneEnPaquetes,
    @Default(1) int cantidadPaquetes,
    @Default('') String codigoInterno,
    @Default(false) bool tieneDescuento,
  }) = _Producto;

  factory Producto.fromJson(Map<String, dynamic> json) => _$ProductoFromJson(json);
}
