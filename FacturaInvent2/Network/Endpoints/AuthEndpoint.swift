//
//  AuthEndpoint.swift
//  FacturaInvent2
//

import Foundation

enum AuthEndpoint {

    static func me() async throws -> Usuario {
        try await APIClient.shared.get("auth/me")
    }

    static func usuarios() async throws -> [Usuario] {
        try await APIClient.shared.get("auth/usuarios")
    }

    struct UsuarioNuevo: Encodable {
        let nombre: String
        let username: String
        let password: String
        let rol: String
    }

    static func crearUsuario(nombre: String, username: String, password: String, rol: String) async throws -> Usuario {
        try await APIClient.shared.post(
            "auth/usuarios",
            body: UsuarioNuevo(nombre: nombre, username: username, password: password, rol: rol)
        )
    }
}
