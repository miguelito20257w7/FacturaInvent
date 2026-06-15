//
//  EmpresasEndpoint.swift
//  FacturaInvent2
//

import Foundation

enum EmpresasEndpoint {

    private struct EmpresaPayload: Encodable {
        let nombre: String
        let nit: String
    }

    static func listar() async throws -> [Empresa] {
        try await APIClient.shared.get("empresas")
    }

    static func crear(nombre: String, nit: String) async throws -> Empresa {
        try await APIClient.shared.post("empresas", body: EmpresaPayload(nombre: nombre, nit: nit))
    }

    static func actualizar(id: Int, nombre: String, nit: String) async throws -> Empresa {
        try await APIClient.shared.put("empresas/\(id)", body: EmpresaPayload(nombre: nombre, nit: nit))
    }

    static func eliminar(id: Int) async throws {
        try await APIClient.shared.delete("empresas/\(id)")
    }

    /// Busca la empresa por NIT; útil al importar un XML.
    static func buscarPorNIT(_ nit: String) async throws -> Empresa? {
        let todas = try await listar()
        return todas.first { $0.nit == nit }
    }
}
