//
//  empresas.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//
import Foundation
import SwiftData

@Model
class Empresa { //declaro que va a haber una clase llamada empresa
    var nombre : String = "" // que vba a tener estos valores
    var nit : String = ""
    @Relationship(deleteRule: .cascade)
    var productos: [Producto]? = []

    init(nombre: String, nit: String) { // aca los iniciamos
        self.nombre = nombre
        self.nit = nit
    }
}

@Model
class Producto { //lo mismo aca , va a haber una clase llamada productos
    var codigoFactura: String = ""
    var codigoBarras: String = ""
    var nombre: String = ""
    var codigoDeBarrasAutomatico: Bool = false
    var cantidadProductos: Int = 0
    var precio: Int = 0
    var precioDividido: Int = 1
    var vieneEnPaquetes: Bool = false
    var cantidadPaquetes: Int = 1
    var empresa: Empresa?
    var codigoInterno: String = ""
    var tieneDescuento: Bool = false

    init(codigoFactura: String, codigoBarras: String, nombre: String) {
        self.codigoFactura = codigoFactura
        self.codigoBarras = codigoBarras
        self.nombre = nombre
        self.codigoDeBarrasAutomatico = false
        self.cantidadProductos = 0
        self.precioDividido = 1
        self.cantidadPaquetes = 1
        self.vieneEnPaquetes = false
        self.codigoInterno = ""
        self.tieneDescuento = false

    }
}

struct ProductoImport: Identifiable {
    let id = UUID()
    var codigo: String
    var codigoBarras: String
    var nombre: String
    var cantidad: String
    var precioSinIVA: String
    var vieneEnPaquetes: Bool
    var cantidadPaquetes: Int
    var codigoBarrasAutomatico: Bool
    var codigoInterno: String
    var tieneDescuento: Bool
    var porcentajeDescuento: Double
}
