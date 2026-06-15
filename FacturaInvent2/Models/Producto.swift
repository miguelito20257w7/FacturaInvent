//
//  Producto.swift
//  FacturaInvent2
//

import Foundation

struct Producto: Codable, Identifiable, Hashable {
    let id: Int
    let empresaId: Int
    var codigoFactura: String?
    var codigoBarras: String?
    var nombre: String
    var cantidadProductos: Int
    var precio: Int
    var precioDividido: Int
    var vieneEnPaquetes: Bool
    var cantidadPaquetes: Int
    var codigoInterno: String?
    var tieneDescuento: Bool
    var codigoBarrasAutomatico: Bool
}

/// Payload para crear o editar un producto.
struct ProductoNuevo: Codable {
    var codigoFactura: String?
    var codigoBarras: String?
    var nombre: String
    var cantidadProductos: Int = 0
    var precio: Int = 0
    var precioDividido: Int = 1
    var vieneEnPaquetes: Bool = false
    var cantidadPaquetes: Int = 1
    var codigoInterno: String?
    var tieneDescuento: Bool = false
    var codigoBarrasAutomatico: Bool = false
}

/// Un producto parseado del XML DIAN, listo para la importación masiva.
struct ProductoImportado: Codable, Identifiable {
    var id: String { (codigoFactura ?? "") + "|" + (codigoBarras ?? "") + "|" + nombre }
    var codigoFactura: String?
    var codigoBarras: String?
    var nombre: String
    var cantidad: Int
    var precio: Int
    var tieneDescuento: Bool

    enum CodingKeys: String, CodingKey {
        case codigoFactura, codigoBarras, nombre, cantidad, precio, tieneDescuento
    }
}

struct ResumenImportacion: Codable {
    let creados: Int
    let actualizados: Int
}
