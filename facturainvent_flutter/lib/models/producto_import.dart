import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'empresa.dart';

part 'producto_import.freezed.dart';

@freezed
class ProductoImport with _$ProductoImport {
  const ProductoImport._();

  const factory ProductoImport({
    required String id,
    @Default('') String codigo,
    @Default('') String codigoBarras,
    @Default('') String nombre,
    @Default('') String cantidad,
    @Default('') String precioSinIVA,
    @Default(false) bool vieneEnPaquetes,
    @Default(1) int cantidadPaquetes,
    @Default(false) bool codigoBarrasAutomatico,
    @Default('') String codigoInterno,
    @Default(false) bool tieneDescuento,
    @Default(0.0) double porcentajeDescuento,
    Empresa? empresa,
  }) = _ProductoImport;

  factory ProductoImport.create({
    String codigo = '',
    String codigoBarras = '',
    String nombre = '',
    String cantidad = '',
    String precioSinIVA = '',
    bool vieneEnPaquetes = false,
    int cantidadPaquetes = 1,
    bool codigoBarrasAutomatico = false,
    String codigoInterno = '',
    bool tieneDescuento = false,
    double porcentajeDescuento = 0.0,
    Empresa? empresa,
  }) {
    return ProductoImport(
      id: const Uuid().v4(),
      codigo: codigo,
      codigoBarras: codigoBarras,
      nombre: nombre,
      cantidad: cantidad,
      precioSinIVA: precioSinIVA,
      vieneEnPaquetes: vieneEnPaquetes,
      cantidadPaquetes: cantidadPaquetes,
      codigoBarrasAutomatico: codigoBarrasAutomatico,
      codigoInterno: codigoInterno,
      tieneDescuento: tieneDescuento,
      porcentajeDescuento: porcentajeDescuento,
      empresa: empresa,
    );
  }
}
