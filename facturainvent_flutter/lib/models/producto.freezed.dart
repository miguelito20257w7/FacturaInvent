// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'producto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Producto _$ProductoFromJson(Map<String, dynamic> json) {
  return _Producto.fromJson(json);
}

/// @nodoc
mixin _$Producto {
  String? get id => throw _privateConstructorUsedError;
  String? get empresaId => throw _privateConstructorUsedError;
  String get codigoFactura => throw _privateConstructorUsedError;
  String get codigoBarras => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  bool get codigoDeBarrasAutomatico => throw _privateConstructorUsedError;
  int get cantidadProductos => throw _privateConstructorUsedError;
  int get precio => throw _privateConstructorUsedError;
  int get precioDividido => throw _privateConstructorUsedError;
  bool get vieneEnPaquetes => throw _privateConstructorUsedError;
  int get cantidadPaquetes => throw _privateConstructorUsedError;
  String get codigoInterno => throw _privateConstructorUsedError;
  bool get tieneDescuento => throw _privateConstructorUsedError;

  /// Serializes this Producto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Producto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductoCopyWith<Producto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductoCopyWith<$Res> {
  factory $ProductoCopyWith(Producto value, $Res Function(Producto) then) =
      _$ProductoCopyWithImpl<$Res, Producto>;
  @useResult
  $Res call({
    String? id,
    String? empresaId,
    String codigoFactura,
    String codigoBarras,
    String nombre,
    bool codigoDeBarrasAutomatico,
    int cantidadProductos,
    int precio,
    int precioDividido,
    bool vieneEnPaquetes,
    int cantidadPaquetes,
    String codigoInterno,
    bool tieneDescuento,
  });
}

/// @nodoc
class _$ProductoCopyWithImpl<$Res, $Val extends Producto>
    implements $ProductoCopyWith<$Res> {
  _$ProductoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Producto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? empresaId = freezed,
    Object? codigoFactura = null,
    Object? codigoBarras = null,
    Object? nombre = null,
    Object? codigoDeBarrasAutomatico = null,
    Object? cantidadProductos = null,
    Object? precio = null,
    Object? precioDividido = null,
    Object? vieneEnPaquetes = null,
    Object? cantidadPaquetes = null,
    Object? codigoInterno = null,
    Object? tieneDescuento = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            empresaId: freezed == empresaId
                ? _value.empresaId
                : empresaId // ignore: cast_nullable_to_non_nullable
                      as String?,
            codigoFactura: null == codigoFactura
                ? _value.codigoFactura
                : codigoFactura // ignore: cast_nullable_to_non_nullable
                      as String,
            codigoBarras: null == codigoBarras
                ? _value.codigoBarras
                : codigoBarras // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            codigoDeBarrasAutomatico: null == codigoDeBarrasAutomatico
                ? _value.codigoDeBarrasAutomatico
                : codigoDeBarrasAutomatico // ignore: cast_nullable_to_non_nullable
                      as bool,
            cantidadProductos: null == cantidadProductos
                ? _value.cantidadProductos
                : cantidadProductos // ignore: cast_nullable_to_non_nullable
                      as int,
            precio: null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                      as int,
            precioDividido: null == precioDividido
                ? _value.precioDividido
                : precioDividido // ignore: cast_nullable_to_non_nullable
                      as int,
            vieneEnPaquetes: null == vieneEnPaquetes
                ? _value.vieneEnPaquetes
                : vieneEnPaquetes // ignore: cast_nullable_to_non_nullable
                      as bool,
            cantidadPaquetes: null == cantidadPaquetes
                ? _value.cantidadPaquetes
                : cantidadPaquetes // ignore: cast_nullable_to_non_nullable
                      as int,
            codigoInterno: null == codigoInterno
                ? _value.codigoInterno
                : codigoInterno // ignore: cast_nullable_to_non_nullable
                      as String,
            tieneDescuento: null == tieneDescuento
                ? _value.tieneDescuento
                : tieneDescuento // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductoImplCopyWith<$Res>
    implements $ProductoCopyWith<$Res> {
  factory _$$ProductoImplCopyWith(
    _$ProductoImpl value,
    $Res Function(_$ProductoImpl) then,
  ) = __$$ProductoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? empresaId,
    String codigoFactura,
    String codigoBarras,
    String nombre,
    bool codigoDeBarrasAutomatico,
    int cantidadProductos,
    int precio,
    int precioDividido,
    bool vieneEnPaquetes,
    int cantidadPaquetes,
    String codigoInterno,
    bool tieneDescuento,
  });
}

/// @nodoc
class __$$ProductoImplCopyWithImpl<$Res>
    extends _$ProductoCopyWithImpl<$Res, _$ProductoImpl>
    implements _$$ProductoImplCopyWith<$Res> {
  __$$ProductoImplCopyWithImpl(
    _$ProductoImpl _value,
    $Res Function(_$ProductoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Producto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? empresaId = freezed,
    Object? codigoFactura = null,
    Object? codigoBarras = null,
    Object? nombre = null,
    Object? codigoDeBarrasAutomatico = null,
    Object? cantidadProductos = null,
    Object? precio = null,
    Object? precioDividido = null,
    Object? vieneEnPaquetes = null,
    Object? cantidadPaquetes = null,
    Object? codigoInterno = null,
    Object? tieneDescuento = null,
  }) {
    return _then(
      _$ProductoImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        empresaId: freezed == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String?,
        codigoFactura: null == codigoFactura
            ? _value.codigoFactura
            : codigoFactura // ignore: cast_nullable_to_non_nullable
                  as String,
        codigoBarras: null == codigoBarras
            ? _value.codigoBarras
            : codigoBarras // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        codigoDeBarrasAutomatico: null == codigoDeBarrasAutomatico
            ? _value.codigoDeBarrasAutomatico
            : codigoDeBarrasAutomatico // ignore: cast_nullable_to_non_nullable
                  as bool,
        cantidadProductos: null == cantidadProductos
            ? _value.cantidadProductos
            : cantidadProductos // ignore: cast_nullable_to_non_nullable
                  as int,
        precio: null == precio
            ? _value.precio
            : precio // ignore: cast_nullable_to_non_nullable
                  as int,
        precioDividido: null == precioDividido
            ? _value.precioDividido
            : precioDividido // ignore: cast_nullable_to_non_nullable
                  as int,
        vieneEnPaquetes: null == vieneEnPaquetes
            ? _value.vieneEnPaquetes
            : vieneEnPaquetes // ignore: cast_nullable_to_non_nullable
                  as bool,
        cantidadPaquetes: null == cantidadPaquetes
            ? _value.cantidadPaquetes
            : cantidadPaquetes // ignore: cast_nullable_to_non_nullable
                  as int,
        codigoInterno: null == codigoInterno
            ? _value.codigoInterno
            : codigoInterno // ignore: cast_nullable_to_non_nullable
                  as String,
        tieneDescuento: null == tieneDescuento
            ? _value.tieneDescuento
            : tieneDescuento // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductoImpl implements _Producto {
  const _$ProductoImpl({
    this.id,
    this.empresaId,
    this.codigoFactura = '',
    this.codigoBarras = '',
    this.nombre = '',
    this.codigoDeBarrasAutomatico = false,
    this.cantidadProductos = 0,
    this.precio = 0,
    this.precioDividido = 1,
    this.vieneEnPaquetes = false,
    this.cantidadPaquetes = 1,
    this.codigoInterno = '',
    this.tieneDescuento = false,
  });

  factory _$ProductoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductoImplFromJson(json);

  @override
  final String? id;
  @override
  final String? empresaId;
  @override
  @JsonKey()
  final String codigoFactura;
  @override
  @JsonKey()
  final String codigoBarras;
  @override
  @JsonKey()
  final String nombre;
  @override
  @JsonKey()
  final bool codigoDeBarrasAutomatico;
  @override
  @JsonKey()
  final int cantidadProductos;
  @override
  @JsonKey()
  final int precio;
  @override
  @JsonKey()
  final int precioDividido;
  @override
  @JsonKey()
  final bool vieneEnPaquetes;
  @override
  @JsonKey()
  final int cantidadPaquetes;
  @override
  @JsonKey()
  final String codigoInterno;
  @override
  @JsonKey()
  final bool tieneDescuento;

  @override
  String toString() {
    return 'Producto(id: $id, empresaId: $empresaId, codigoFactura: $codigoFactura, codigoBarras: $codigoBarras, nombre: $nombre, codigoDeBarrasAutomatico: $codigoDeBarrasAutomatico, cantidadProductos: $cantidadProductos, precio: $precio, precioDividido: $precioDividido, vieneEnPaquetes: $vieneEnPaquetes, cantidadPaquetes: $cantidadPaquetes, codigoInterno: $codigoInterno, tieneDescuento: $tieneDescuento)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.codigoFactura, codigoFactura) ||
                other.codigoFactura == codigoFactura) &&
            (identical(other.codigoBarras, codigoBarras) ||
                other.codigoBarras == codigoBarras) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(
                  other.codigoDeBarrasAutomatico,
                  codigoDeBarrasAutomatico,
                ) ||
                other.codigoDeBarrasAutomatico == codigoDeBarrasAutomatico) &&
            (identical(other.cantidadProductos, cantidadProductos) ||
                other.cantidadProductos == cantidadProductos) &&
            (identical(other.precio, precio) || other.precio == precio) &&
            (identical(other.precioDividido, precioDividido) ||
                other.precioDividido == precioDividido) &&
            (identical(other.vieneEnPaquetes, vieneEnPaquetes) ||
                other.vieneEnPaquetes == vieneEnPaquetes) &&
            (identical(other.cantidadPaquetes, cantidadPaquetes) ||
                other.cantidadPaquetes == cantidadPaquetes) &&
            (identical(other.codigoInterno, codigoInterno) ||
                other.codigoInterno == codigoInterno) &&
            (identical(other.tieneDescuento, tieneDescuento) ||
                other.tieneDescuento == tieneDescuento));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    codigoFactura,
    codigoBarras,
    nombre,
    codigoDeBarrasAutomatico,
    cantidadProductos,
    precio,
    precioDividido,
    vieneEnPaquetes,
    cantidadPaquetes,
    codigoInterno,
    tieneDescuento,
  );

  /// Create a copy of Producto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductoImplCopyWith<_$ProductoImpl> get copyWith =>
      __$$ProductoImplCopyWithImpl<_$ProductoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductoImplToJson(this);
  }
}

abstract class _Producto implements Producto {
  const factory _Producto({
    final String? id,
    final String? empresaId,
    final String codigoFactura,
    final String codigoBarras,
    final String nombre,
    final bool codigoDeBarrasAutomatico,
    final int cantidadProductos,
    final int precio,
    final int precioDividido,
    final bool vieneEnPaquetes,
    final int cantidadPaquetes,
    final String codigoInterno,
    final bool tieneDescuento,
  }) = _$ProductoImpl;

  factory _Producto.fromJson(Map<String, dynamic> json) =
      _$ProductoImpl.fromJson;

  @override
  String? get id;
  @override
  String? get empresaId;
  @override
  String get codigoFactura;
  @override
  String get codigoBarras;
  @override
  String get nombre;
  @override
  bool get codigoDeBarrasAutomatico;
  @override
  int get cantidadProductos;
  @override
  int get precio;
  @override
  int get precioDividido;
  @override
  bool get vieneEnPaquetes;
  @override
  int get cantidadPaquetes;
  @override
  String get codigoInterno;
  @override
  bool get tieneDescuento;

  /// Create a copy of Producto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductoImplCopyWith<_$ProductoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
