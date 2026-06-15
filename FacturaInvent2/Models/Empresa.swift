//
//  Empresa.swift
//  FacturaInvent2
//
//  Modelo Codable plano: el dato vive en PostgreSQL, no hay SwiftData.
//

import Foundation

struct Empresa: Codable, Identifiable, Hashable {
    let id: Int
    var nombre: String
    var nit: String
    var createdAt: String?
}
