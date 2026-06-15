//
//  ProductosEndpoint.swift
//  FacturaInvent2
//

import Foundation

enum ProductosEndpoint {

    static func listar(empresaId: Int, buscar: String = "") async throws -> [Producto] {
        var query: [URLQueryItem] = []
        if !buscar.isEmpty { query.append(URLQueryItem(name: "buscar", value: buscar)) }
        return try await APIClient.shared.get("empresas/\(empresaId)/productos", query: query)
    }

    static func buscarGlobal(_ texto: String) async throws -> [Producto] {
        try await APIClient.shared.get(
            "productos/buscar", query: [URLQueryItem(name: "q", value: texto)]
        )
    }

    static func crear(empresaId: Int, producto: ProductoNuevo) async throws -> Producto {
        try await APIClient.shared.post("empresas/\(empresaId)/productos", body: producto)
    }

    static func actualizar(id: Int, producto: ProductoNuevo) async throws -> Producto {
        try await APIClient.shared.put("productos/\(id)", body: producto)
    }

    static func eliminar(id: Int) async throws {
        try await APIClient.shared.delete("productos/\(id)")
    }

    /// Importación masiva desde XML DIAN. El servidor deduplica por
    /// codigo_factura y codigo_barras (misma lógica que v1).
    static func importar(empresaId: Int, productos: [ProductoImportado]) async throws -> ResumenImportacion {
        try await APIClient.shared.post("empresas/\(empresaId)/productos/importar", body: productos)
    }

    /// Descarga el inventario de la empresa en Excel y retorna la URL local.
    static func exportarExcel(empresaId: Int, nit: String) async throws -> URL {
        try await APIClient.shared.descargarArchivo(
            "empresas/\(empresaId)/productos/export.xlsx",
            nombre: "inventario-\(nit).xlsx"
        )
    }
}
