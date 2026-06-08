// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductoImpl _$$ProductoImplFromJson(Map<String, dynamic> json) =>
    _$ProductoImpl(
      id: json['id'] as String?,
      empresaId: json['empresaId'] as String?,
      codigoFactura: json['codigoFactura'] as String? ?? '',
      codigoBarras: json['codigoBarras'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      codigoDeBarrasAutomatico:
          json['codigoDeBarrasAutomatico'] as bool? ?? false,
      cantidadProductos: (json['cantidadProductos'] as num?)?.toInt() ?? 0,
      precio: (json['precio'] as num?)?.toInt() ?? 0,
      precioDividido: (json['precioDividido'] as num?)?.toInt() ?? 1,
      vieneEnPaquetes: json['vieneEnPaquetes'] as bool? ?? false,
      cantidadPaquetes: (json['cantidadPaquetes'] as num?)?.toInt() ?? 1,
      codigoInterno: json['codigoInterno'] as String? ?? '',
      tieneDescuento: json['tieneDescuento'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProductoImplToJson(_$ProductoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresaId': instance.empresaId,
      'codigoFactura': instance.codigoFactura,
      'codigoBarras': instance.codigoBarras,
      'nombre': instance.nombre,
      'codigoDeBarrasAutomatico': instance.codigoDeBarrasAutomatico,
      'cantidadProductos': instance.cantidadProductos,
      'precio': instance.precio,
      'precioDividido': instance.precioDividido,
      'vieneEnPaquetes': instance.vieneEnPaquetes,
      'cantidadPaquetes': instance.cantidadPaquetes,
      'codigoInterno': instance.codigoInterno,
      'tieneDescuento': instance.tieneDescuento,
    };
