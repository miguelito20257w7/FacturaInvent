//
//  AuthService.swift
//  FacturaInvent v2 client foundation
//
//  Login / refresh / logout against the v2 auth endpoints.
//

import Foundation

@MainActor
@Observable
final class AuthService {
    private(set) var isAuthenticated = false

    private let client = APIClient.shared
    private let tokens = TokenStore.shared

    init() {
        Task { isAuthenticated = await tokens.isAuthenticated }
    }

    /// email + password -> stores access + refresh tokens.
    func login(email: String, password: String) async throws {
        let pair: TokenPair = try await client.post(
            "/auth/login",
            body: LoginRequest(email: email, password: password),
            authorized: false
        )
        await tokens.save(pair)
        isAuthenticated = true
    }

    /// Revoke the refresh token server-side and clear local storage.
    func logout() async {
        if let refresh = await tokens.refreshToken {
            _ = try? await client.post(
                "/auth/logout",
                body: LogoutRequest(refreshToken: refresh),
                authorized: false
            ) as Empty
        }
        await tokens.clear()
        isAuthenticated = false
    }

    /// Request a password-reset email (always succeeds to avoid enumeration).
    func requestPasswordReset(email: String) async throws {
        struct Req: Encodable { let email: String }
        struct Msg: Decodable { let detail: String }
        let _: Msg = try await client.post(
            "/auth/password-reset/request", body: Req(email: email), authorized: false)
    }
}

/// Example catalog calls showing the authorized-request pattern.
@MainActor
final class CatalogService {
    private let client = APIClient.shared

    func suppliers(query: String? = nil) async throws -> [SupplierDTO] {
        var path = "/suppliers"
        if let query, !query.isEmpty {
            path += "?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        return try await client.get(path)
    }

    func products(query: String? = nil) async throws -> [ProductDTO] {
        var path = "/products"
        if let query, !query.isEmpty {
            path += "?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        return try await client.get(path)
    }

    /// Parse a DIAN invoice XML (raw body) with conflict detection.
    func parseInvoice(xml: Data) async throws -> ParseResponse {
        try await client.postRaw("/invoices/parse", xml: xml)
    }
}
