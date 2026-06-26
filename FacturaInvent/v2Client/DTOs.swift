//
//  DTOs.swift
//  FacturaInvent v2 client foundation
//
//  Codable models mirroring the FastAPI Pydantic schemas. Keys use
//  .convertFromSnakeCase, so Swift camelCase maps to backend snake_case.
//

import Foundation

// MARK: - Auth

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

struct LogoutRequest: Encodable {
    let refreshToken: String
}

struct TokenPair: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
}

struct AccessTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}

// MARK: - Catalog

struct SupplierDTO: Decodable, Identifiable {
    let id: UUID
    let organizationId: UUID
    let name: String?
    let nit: String?
    let isActive: Bool
    let createdAt: Date
}

struct ProductDTO: Decodable, Identifiable {
    let id: UUID
    let organizationId: UUID
    let supplierId: UUID?
    let internalCode: String
    let supplierItemCode: String
    let barcode: String
    let barcodeFromInvoice: Bool
    let name: String
    let lastUnitPrice: Decimal
    let lastQuantity: Int
    let comesInPackages: Bool
    let unitsPerPackage: Int
    let hasDiscount: Bool
    let discountPercent: Decimal
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Invoice parse (DIAN)

struct ParsedSupplier: Decodable {
    let nit: String
    let name: String
    let existingSupplierId: UUID?
}

struct ParsedLine: Decodable {
    let name: String
    let supplierItemCode: String
    let barcode: String
    let quantity: Decimal
    let unitPrice: Decimal
    let hasDiscount: Bool
    let status: String            // "existing" | "new"
    let existingProductId: UUID?
}

struct ParseResponse: Decodable {
    let supplier: ParsedSupplier
    let lines: [ParsedLine]
    let lineCount: Int
}
