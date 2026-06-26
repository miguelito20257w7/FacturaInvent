//
//  APIClient.swift
//  FacturaInvent v2 client foundation
//
//  Networking layer for the FastAPI backend at api.swiftydevs.dev.
//  ADDITIVE: not wired into the v1 Xcode target — add to a v2 target when ready.
//

import Foundation

enum APIConfig {
    /// Base URL of the v2 backend.
    static let baseURL = URL(string: "https://api.swiftydevs.dev")!
}

enum APIError: Error, LocalizedError {
    case notAuthenticated
    case unauthorized
    case server(status: Int, detail: String?)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "No active session"
        case .unauthorized: return "Session expired"
        case let .server(status, detail): return detail ?? "Server error (\(status))"
        case let .decoding(error): return "Decoding error: \(error.localizedDescription)"
        case let .transport(error): return error.localizedDescription
        }
    }
}

/// Minimal async JSON client with bearer auth and one-shot 401→refresh retry.
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let tokens: TokenStore
    private var isRefreshing = false

    init(session: URLSession = .shared, tokens: TokenStore = .shared) {
        self.session = session
        self.tokens = tokens
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            if let date = ISO8601.full.date(from: raw) ?? ISO8601.plain.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Bad date: \(raw)"))
        }
        return d
    }()

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    // MARK: - Public verbs

    func get<R: Decodable>(_ path: String, authorized: Bool = true) async throws -> R {
        try await send(path: path, method: "GET", body: Optional<Empty>.none, authorized: authorized)
    }

    func post<B: Encodable, R: Decodable>(_ path: String, body: B, authorized: Bool = true) async throws -> R {
        try await send(path: path, method: "POST", body: body, authorized: authorized)
    }

    func patch<B: Encodable, R: Decodable>(_ path: String, body: B, authorized: Bool = true) async throws -> R {
        try await send(path: path, method: "PATCH", body: body, authorized: authorized)
    }

    @discardableResult
    func delete<R: Decodable>(_ path: String, authorized: Bool = true) async throws -> R {
        try await send(path: path, method: "DELETE", body: Optional<Empty>.none, authorized: authorized)
    }

    /// POST raw bytes (used for /invoices/parse, which takes the XML as the body).
    func postRaw<R: Decodable>(_ path: String, xml: Data, contentType: String = "application/xml") async throws -> R {
        var request = URLRequest(url: APIConfig.baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = xml
        if let token = await tokens.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request, retryOn401: true)
    }

    // MARK: - Core

    private func send<B: Encodable, R: Decodable>(
        path: String, method: String, body: B?, authorized: Bool
    ) async throws -> R {
        var request = URLRequest(url: APIConfig.baseURL.appendingPathComponent(path))
        request.httpMethod = method
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try Self.encoder.encode(body)
        }
        if authorized {
            guard let token = await tokens.accessToken else { throw APIError.notAuthenticated }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request, retryOn401: authorized)
    }

    private func perform<R: Decodable>(_ request: URLRequest, retryOn401: Bool) async throws -> R {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(status: -1, detail: nil)
        }

        if http.statusCode == 401, retryOn401, await refreshAccessToken() {
            var retried = request
            if let token = await tokens.accessToken {
                retried.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return try await perform(retried, retryOn401: false)
        }

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            throw APIError.server(status: http.statusCode, detail: Self.decodeDetail(data))
        }

        if R.self == Empty.self { return Empty() as! R }
        do {
            return try Self.decoder.decode(R.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    /// Exchange the stored refresh token for a new access token. Returns success.
    private func refreshAccessToken() async -> Bool {
        guard !isRefreshing, let refresh = await tokens.refreshToken else { return false }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            let resp: AccessTokenResponse = try await post(
                "/auth/refresh", body: RefreshRequest(refreshToken: refresh), authorized: false)
            await tokens.updateAccessToken(resp.accessToken)
            return true
        } catch {
            await tokens.clear()
            return false
        }
    }

    private static func decodeDetail(_ data: Data) -> String? {
        struct Detail: Decodable { let detail: String? }
        return (try? JSONDecoder().decode(Detail.self, from: data))?.detail
    }
}

/// Empty request/response placeholder.
struct Empty: Codable {}

private enum ISO8601 {
    static let full: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    static let plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
