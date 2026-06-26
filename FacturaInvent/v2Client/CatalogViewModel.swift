//
//  CatalogViewModel.swift
//  FacturaInvent v2 client foundation
//
//  Bridge view model for the supplier-ingestion / catalog flow. v1 SwiftUI
//  views are pointed at this one-by-one during cutover. NOT compiled here.
//

import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    // State the views observe
    var suppliers: [SupplierDTO] = []
    var products: [ProductDTO] = []
    var isLoading = false
    var errorMessage: String?

    private let client = APIClient.shared
    private let tokens = TokenStore.shared

    // MARK: - Reads

    func loadSuppliers(query: String? = nil) async {
        await run { self.suppliers = try await self.client.get(Self.path("/suppliers", query: query)) }
    }

    func loadProducts(query: String? = nil) async {
        await run { self.products = try await self.client.get(Self.path("/products", query: query)) }
    }

    // MARK: - Invoice ingestion

    /// Parse a DIAN XML invoice (raw body) → supplier + lines flagged existing/new.
    func parseInvoice(xml: Data) async throws -> ParseResponse {
        try await client.postRaw("/invoices/parse", xml: xml)
    }

    /// Persist the reviewed products (creates/updates) after the user confirms.
    func importReviewed(_ request: CatalogImportRequest) async throws -> CatalogImportResult {
        try await client.post("/invoices/import", body: request)
    }

    // MARK: - XLSX export (binary response)

    /// Build the POS .xlsx for the reviewed rows; returns the file bytes to share/save.
    func exportXLSX(_ request: CatalogExportRequest) async throws -> Data {
        var req = URLRequest(url: APIConfig.baseURL.appendingPathComponent("/export/xlsx"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        req.httpBody = try encoder.encode(request)
        if let token = await tokens.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.server(status: -1, detail: nil) }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            throw APIError.server(status: http.statusCode, detail: nil)
        }
        return data
    }

    // MARK: - Helpers

    private func run(_ work: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { try await work() } catch { errorMessage = error.localizedDescription }
    }

    private static func path(_ base: String, query: String?) -> String {
        guard let query, !query.isEmpty else { return base }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "\(base)?q=\(encoded)"
    }
}

// MARK: - DTOs (mirror app/schemas/invoices.py + export.py)

struct CatalogImportSupplier: Encodable {
    let id: UUID?
    let nit: String?
    let name: String?
}

struct CatalogImportProduct: Encodable {
    var existingProductId: UUID? = nil
    var name: String
    var internalCode: String = ""
    var supplierItemCode: String = ""
    var barcode: String = ""
    var barcodeFromInvoice: Bool = false
    var lastUnitPrice: Decimal = 0
    var lastQuantity: Int = 0
    var comesInPackages: Bool = false
    var unitsPerPackage: Int = 1
    var hasDiscount: Bool = false
    var discountPercent: Decimal = 0
}

struct CatalogImportRequest: Encodable {
    let supplier: CatalogImportSupplier
    let products: [CatalogImportProduct]
}

struct CatalogImportResult: Decodable {
    let supplierId: UUID?
    let created: Int
    let updated: Int
}

struct CatalogExportRow: Encodable {
    var internalCode: String = ""
    var quantity: Decimal = 0
    var unitsPerPackage: Int = 1
    var unitPrice: Decimal = 0
    var hasDiscount: Bool = false
    var discountPercent: Decimal = 0
}

struct CatalogExportRequest: Encodable {
    let products: [CatalogExportRow]
}
