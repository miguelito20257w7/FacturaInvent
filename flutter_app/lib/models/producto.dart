class Producto {
  Producto({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.cantidadProductos,
    required this.precio,
    this.codigoFactura,
    this.codigoBarras,
    this.codigoInterno,
    this.precioDividido = 1,
    this.vieneEnPaquetes = false,
    this.cantidadPaquetes = 1,
    this.tieneDescuento = false,
    this.codigoBarrasAutomatico = false,
  });

  final int id;
  final int empresaId;
  final String nombre;
  final int cantidadProductos;
  final int precio;
  final String? codigoFactura;
  final String? codigoBarras;
  final String? codigoInterno;
  final int precioDividido;
  final bool vieneEnPaquetes;
  final int cantidadPaquetes;
  final bool tieneDescuento;
  final bool codigoBarrasAutomatico;

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'] as int,
        empresaId: json['empresa_id'] as int,
        nombre: json['nombre'] as String,
        cantidadProductos: json['cantidad_productos'] as int? ?? 0,
        precio: json['precio'] as int? ?? 0,
        codigoFactura: json['codigo_factura'] as String?,
        codigoBarras: json['codigo_barras'] as String?,
        codigoInterno: json['codigo_interno'] as String?,
        precioDividido: json['precio_dividido'] as int? ?? 1,
        vieneEnPaquetes: json['viene_en_paquetes'] as bool? ?? false,
        cantidadPaquetes: json['cantidad_paquetes'] as int? ?? 1,
        tieneDescuento: json['tiene_descuento'] as bool? ?? false,
        codigoBarrasAutomatico: json['codigo_barras_automatico'] as bool? ?? false,
      );
}
