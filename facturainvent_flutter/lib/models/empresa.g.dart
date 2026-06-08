// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmpresaImpl _$$EmpresaImplFromJson(Map<String, dynamic> json) =>
    _$EmpresaImpl(
      id: json['id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
    );

Map<String, dynamic> _$$EmpresaImplToJson(_$EmpresaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'nit': instance.nit,
    };
