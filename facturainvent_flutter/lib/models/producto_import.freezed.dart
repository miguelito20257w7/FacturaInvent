// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'producto_import.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductoImport {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get codigoBarras => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get cantidad => throw _privateConstructorUsedError;
  String get precioSinIVA => throw _privateConstructorUsedError;
  bool get vieneEnPaquetes => throw _privateConstructorUsedError;
  int get cantidadPaquetes => throw _privateConstructorUsedError;
  bool get codigoBarrasAutomatico => throw _privateConstructorUsedError;
  String get codigoInterno => throw _privateConstructorUsedError;
  bool get tieneDescuento => throw _privateConstructorUsedError;
  double get porcentajeDescuento => throw _privateConstructorUsedError;
  Empresa? get empresa => throw _privateConstructorUsedError;

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductoImportCopyWith<ProductoImport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductoImportCopyWith<$Res> {
  factory $ProductoImportCopyWith(
    ProductoImport value,
    $Res Function(ProductoImport) then,
  ) = _$ProductoImportCopyWithImpl<$Res, ProductoImport>;
  @useResult
  $Res call({
    String id,
    String codigo,
    String codigoBarras,
    String nombre,
    String cantidad,
    String precioSinIVA,
    bool vieneEnPaquetes,
    int cantidadPaquetes,
    bool codigoBarrasAutomatico,
    String codigoInterno,
    bool tieneDescuento,
    double porcentajeDescuento,
    Empresa? empresa,
  });

  $EmpresaCopyWith<$Res>? get empresa;
}

/// @nodoc
class _$ProductoImportCopyWithImpl<$Res, $Val extends ProductoImport>
    implements $ProductoImportCopyWith<$Res> {
  _$ProductoImportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? codigoBarras = null,
    Object? nombre = null,
    Object? cantidad = null,
    Object? precioSinIVA = null,
    Object? vieneEnPaquetes = null,
    Object? cantidadPaquetes = null,
    Object? codigoBarrasAutomatico = null,
    Object? codigoInterno = null,
    Object? tieneDescuento = null,
    Object? porcentajeDescuento = null,
    Object? empresa = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            codigo: null == codigo
                ? _value.codigo
                : codigo // ignore: cast_nullable_to_non_nullable
                      as String,
            codigoBarras: null == codigoBarras
                ? _value.codigoBarras
                : codigoBarras // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            cantidad: null == cantidad
                ? _value.cantidad
                : cantidad // ignore: cast_nullable_to_non_nullable
                      as String,
            precioSinIVA: null == precioSinIVA
                ? _value.precioSinIVA
                : precioSinIVA // ignore: cast_nullable_to_non_nullable
                      as String,
            vieneEnPaquetes: null == vieneEnPaquetes
                ? _value.vieneEnPaquetes
                : vieneEnPaquetes // ignore: cast_nullable_to_non_nullable
                      as bool,
            cantidadPaquetes: null == cantidadPaquetes
                ? _value.cantidadPaquetes
                : cantidadPaquetes // ignore: cast_nullable_to_non_nullable
                      as int,
            codigoBarrasAutomatico: null == codigoBarrasAutomatico
                ? _value.codigoBarrasAutomatico
                : codigoBarrasAutomatico // ignore: cast_nullable_to_non_nullable
                      as bool,
            codigoInterno: null == codigoInterno
                ? _value.codigoInterno
                : codigoInterno // ignore: cast_nullable_to_non_nullable
                      as String,
            tieneDescuento: null == tieneDescuento
                ? _value.tieneDescuento
                : tieneDescuento // ignore: cast_nullable_to_non_nullable
                      as bool,
            porcentajeDescuento: null == porcentajeDescuento
                ? _value.porcentajeDescuento
                : porcentajeDescuento // ignore: cast_nullable_to_non_nullable
                      as double,
            empresa: freezed == empresa
                ? _value.empresa
                : empresa // ignore: cast_nullable_to_non_nullable
                      as Empresa?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmpresaCopyWith<$Res>? get empresa {
    if (_value.empresa == null) {
      return null;
    }

    return $EmpresaCopyWith<$Res>(_value.empresa!, (value) {
      return _then(_value.copyWith(empresa: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductoImportImplCopyWith<$Res>
    implements $ProductoImportCopyWith<$Res> {
  factory _$$ProductoImportImplCopyWith(
    _$ProductoImportImpl value,
    $Res Function(_$ProductoImportImpl) then,
  ) = __$$ProductoImportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String codigo,
    String codigoBarras,
    String nombre,
    String cantidad,
    String precioSinIVA,
    bool vieneEnPaquetes,
    int cantidadPaquetes,
    bool codigoBarrasAutomatico,
    String codigoInterno,
    bool tieneDescuento,
    double porcentajeDescuento,
    Empresa? empresa,
  });

  @override
  $EmpresaCopyWith<$Res>? get empresa;
}

/// @nodoc
class __$$ProductoImportImplCopyWithImpl<$Res>
    extends _$ProductoImportCopyWithImpl<$Res, _$ProductoImportImpl>
    implements _$$ProductoImportImplCopyWith<$Res> {
  __$$ProductoImportImplCopyWithImpl(
    _$ProductoImportImpl _value,
    $Res Function(_$ProductoImportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? codigoBarras = null,
    Object? nombre = null,
    Object? cantidad = null,
    Object? precioSinIVA = null,
    Object? vieneEnPaquetes = null,
    Object? cantidadPaquetes = null,
    Object? codigoBarrasAutomatico = null,
    Object? codigoInterno = null,
    Object? tieneDescuento = null,
    Object? porcentajeDescuento = null,
    Object? empresa = freezed,
  }) {
    return _then(
      _$ProductoImportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        codigo: null == codigo
            ? _value.codigo
            : codigo // ignore: cast_nullable_to_non_nullable
                  as String,
        codigoBarras: null == codigoBarras
            ? _value.codigoBarras
            : codigoBarras // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        cantidad: null == cantidad
            ? _value.cantidad
            : cantidad // ignore: cast_nullable_to_non_nullable
                  as String,
        precioSinIVA: null == precioSinIVA
            ? _value.precioSinIVA
            : precioSinIVA // ignore: cast_nullable_to_non_nullable
                  as String,
        vieneEnPaquetes: null == vieneEnPaquetes
            ? _value.vieneEnPaquetes
            : vieneEnPaquetes // ignore: cast_nullable_to_non_nullable
                  as bool,
        cantidadPaquetes: null == cantidadPaquetes
            ? _value.cantidadPaquetes
            : cantidadPaquetes // ignore: cast_nullable_to_non_nullable
                  as int,
        codigoBarrasAutomatico: null == codigoBarrasAutomatico
            ? _value.codigoBarrasAutomatico
            : codigoBarrasAutomatico // ignore: cast_nullable_to_non_nullable
                  as bool,
        codigoInterno: null == codigoInterno
            ? _value.codigoInterno
            : codigoInterno // ignore: cast_nullable_to_non_nullable
                  as String,
        tieneDescuento: null == tieneDescuento
            ? _value.tieneDescuento
            : tieneDescuento // ignore: cast_nullable_to_non_nullable
                  as bool,
        porcentajeDescuento: null == porcentajeDescuento
            ? _value.porcentajeDescuento
            : porcentajeDescuento // ignore: cast_nullable_to_non_nullable
                  as double,
        empresa: freezed == empresa
            ? _value.empresa
            : empresa // ignore: cast_nullable_to_non_nullable
                  as Empresa?,
      ),
    );
  }
}

/// @nodoc

class _$ProductoImportImpl extends _ProductoImport {
  const _$ProductoImportImpl({
    required this.id,
    this.codigo = '',
    this.codigoBarras = '',
    this.nombre = '',
    this.cantidad = '',
    this.precioSinIVA = '',
    this.vieneEnPaquetes = false,
    this.cantidadPaquetes = 1,
    this.codigoBarrasAutomatico = false,
    this.codigoInterno = '',
    this.tieneDescuento = false,
    this.porcentajeDescuento = 0.0,
    this.empresa,
  }) : super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String codigo;
  @override
  @JsonKey()
  final String codigoBarras;
  @override
  @JsonKey()
  final String nombre;
  @override
  @JsonKey()
  final String cantidad;
  @override
  @JsonKey()
  final String precioSinIVA;
  @override
  @JsonKey()
  final bool vieneEnPaquetes;
  @override
  @JsonKey()
  final int cantidadPaquetes;
  @override
  @JsonKey()
  final bool codigoBarrasAutomatico;
  @override
  @JsonKey()
  final String codigoInterno;
  @override
  @JsonKey()
  final bool tieneDescuento;
  @override
  @JsonKey()
  final double porcentajeDescuento;
  @override
  final Empresa? empresa;

  @override
  String toString() {
    return 'ProductoImport(id: $id, codigo: $codigo, codigoBarras: $codigoBarras, nombre: $nombre, cantidad: $cantidad, precioSinIVA: $precioSinIVA, vieneEnPaquetes: $vieneEnPaquetes, cantidadPaquetes: $cantidadPaquetes, codigoBarrasAutomatico: $codigoBarrasAutomatico, codigoInterno: $codigoInterno, tieneDescuento: $tieneDescuento, porcentajeDescuento: $porcentajeDescuento, empresa: $empresa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductoImportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.codigoBarras, codigoBarras) ||
                other.codigoBarras == codigoBarras) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.precioSinIVA, precioSinIVA) ||
                other.precioSinIVA == precioSinIVA) &&
            (identical(other.vieneEnPaquetes, vieneEnPaquetes) ||
                other.vieneEnPaquetes == vieneEnPaquetes) &&
            (identical(other.cantidadPaquetes, cantidadPaquetes) ||
                other.cantidadPaquetes == cantidadPaquetes) &&
            (identical(other.codigoBarrasAutomatico, codigoBarrasAutomatico) ||
                other.codigoBarrasAutomatico == codigoBarrasAutomatico) &&
            (identical(other.codigoInterno, codigoInterno) ||
                other.codigoInterno == codigoInterno) &&
            (identical(other.tieneDescuento, tieneDescuento) ||
                other.tieneDescuento == tieneDescuento) &&
            (identical(other.porcentajeDescuento, porcentajeDescuento) ||
                other.porcentajeDescuento == porcentajeDescuento) &&
            (identical(other.empresa, empresa) || other.empresa == empresa));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    codigo,
    codigoBarras,
    nombre,
    cantidad,
    precioSinIVA,
    vieneEnPaquetes,
    cantidadPaquetes,
    codigoBarrasAutomatico,
    codigoInterno,
    tieneDescuento,
    porcentajeDescuento,
    empresa,
  );

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductoImportImplCopyWith<_$ProductoImportImpl> get copyWith =>
      __$$ProductoImportImplCopyWithImpl<_$ProductoImportImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductoImport extends ProductoImport {
  const factory _ProductoImport({
    required final String id,
    final String codigo,
    final String codigoBarras,
    final String nombre,
    final String cantidad,
    final String precioSinIVA,
    final bool vieneEnPaquetes,
    final int cantidadPaquetes,
    final bool codigoBarrasAutomatico,
    final String codigoInterno,
    final bool tieneDescuento,
    final double porcentajeDescuento,
    final Empresa? empresa,
  }) = _$ProductoImportImpl;
  const _ProductoImport._() : super._();

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get codigoBarras;
  @override
  String get nombre;
  @override
  String get cantidad;
  @override
  String get precioSinIVA;
  @override
  bool get vieneEnPaquetes;
  @override
  int get cantidadPaquetes;
  @override
  bool get codigoBarrasAutomatico;
  @override
  String get codigoInterno;
  @override
  bool get tieneDescuento;
  @override
  double get porcentajeDescuento;
  @override
  Empresa? get empresa;

  /// Create a copy of ProductoImport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductoImportImplCopyWith<_$ProductoImportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
