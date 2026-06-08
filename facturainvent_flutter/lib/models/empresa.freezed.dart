// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'empresa.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Empresa _$EmpresaFromJson(Map<String, dynamic> json) {
  return _Empresa.fromJson(json);
}

/// @nodoc
mixin _$Empresa {
  String? get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get nit => throw _privateConstructorUsedError;

  /// Serializes this Empresa to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Empresa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmpresaCopyWith<Empresa> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmpresaCopyWith<$Res> {
  factory $EmpresaCopyWith(Empresa value, $Res Function(Empresa) then) =
      _$EmpresaCopyWithImpl<$Res, Empresa>;
  @useResult
  $Res call({String? id, String nombre, String nit});
}

/// @nodoc
class _$EmpresaCopyWithImpl<$Res, $Val extends Empresa>
    implements $EmpresaCopyWith<$Res> {
  _$EmpresaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Empresa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? nombre = null, Object? nit = null}) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            nit: null == nit
                ? _value.nit
                : nit // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmpresaImplCopyWith<$Res> implements $EmpresaCopyWith<$Res> {
  factory _$$EmpresaImplCopyWith(
    _$EmpresaImpl value,
    $Res Function(_$EmpresaImpl) then,
  ) = __$$EmpresaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String nombre, String nit});
}

/// @nodoc
class __$$EmpresaImplCopyWithImpl<$Res>
    extends _$EmpresaCopyWithImpl<$Res, _$EmpresaImpl>
    implements _$$EmpresaImplCopyWith<$Res> {
  __$$EmpresaImplCopyWithImpl(
    _$EmpresaImpl _value,
    $Res Function(_$EmpresaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Empresa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? nombre = null, Object? nit = null}) {
    return _then(
      _$EmpresaImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        nit: null == nit
            ? _value.nit
            : nit // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmpresaImpl implements _Empresa {
  const _$EmpresaImpl({this.id, this.nombre = '', this.nit = ''});

  factory _$EmpresaImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmpresaImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey()
  final String nombre;
  @override
  @JsonKey()
  final String nit;

  @override
  String toString() {
    return 'Empresa(id: $id, nombre: $nombre, nit: $nit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmpresaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.nit, nit) || other.nit == nit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, nit);

  /// Create a copy of Empresa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmpresaImplCopyWith<_$EmpresaImpl> get copyWith =>
      __$$EmpresaImplCopyWithImpl<_$EmpresaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmpresaImplToJson(this);
  }
}

abstract class _Empresa implements Empresa {
  const factory _Empresa({
    final String? id,
    final String nombre,
    final String nit,
  }) = _$EmpresaImpl;

  factory _Empresa.fromJson(Map<String, dynamic> json) = _$EmpresaImpl.fromJson;

  @override
  String? get id;
  @override
  String get nombre;
  @override
  String get nit;

  /// Create a copy of Empresa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmpresaImplCopyWith<_$EmpresaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
