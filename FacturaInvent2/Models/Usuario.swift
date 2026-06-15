//
//  Usuario.swift
//  FacturaInvent2
//

import Foundation

struct Usuario: Codable, Identifiable, Hashable {
    let id: Int
    var nombre: String
    var username: String
    var rol: String

    var esAdmin: Bool { rol == "admin" }
}

struct LoginResponse: Codable {
    let token: String
    let usuario: Usuario
}
