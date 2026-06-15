//
//  CuadreCajaEndpoint.swift
//  FacturaInvent2
//

import Foundation

enum CuadreCajaEndpoint {

    struct Filtros {
        var fechaDesde: Date?
        var fechaHasta: Date?
        var usuario: String?

        var queryItems: [URLQueryItem] {
            var items: [URLQueryItem] = []
            if let fechaDesde {
                items.append(URLQueryItem(name: "fecha_desde", value: Self.iso(fechaDesde)))
            }
            if let fechaHasta {
                items.append(URLQueryItem(name: "fecha_hasta", value: Self.iso(fechaHasta)))
            }
            if let usuario, !usuario.isEmpty {
                items.append(URLQueryItem(name: "usuario", value: usuario))
            }
            return items
        }

        static func iso(_ fecha: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: fecha)
        }
    }

    static func historial(filtros: Filtros = Filtros(), limit: Int = 200, offset: Int = 0) async throws -> [CuadreCaja] {
        var query = filtros.queryItems
        query.append(URLQueryItem(name: "limit", value: "\(limit)"))
        query.append(URLQueryItem(name: "offset", value: "\(offset)"))
        return try await APIClient.shared.get("cuadres", query: query)
    }

    /// Número de turno siguiente y base anterior (= base del día del último turno).
    static func nuevoTurno() async throws -> NuevoTurno {
        try await APIClient.shared.get("cuadres/nuevo-turno")
    }

    static func crear(_ cuadre: CuadreCajaNuevo) async throws -> CuadreCaja {
        try await APIClient.shared.post("cuadres", body: cuadre)
    }

    static func eliminar(id: Int) async throws {
        try await APIClient.shared.delete("cuadres/\(id)")
    }

    /// Descarga el historial filtrado en Excel y retorna la URL local.
    static func exportarExcel(filtros: Filtros = Filtros()) async throws -> URL {
        try await APIClient.shared.descargarArchivo(
            "cuadres/export.xlsx",
            query: filtros.queryItems,
            nombre: "cuadres-caja.xlsx"
        )
    }
}
