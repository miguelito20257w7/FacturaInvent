//
//  APIClient.swift
//  FacturaInvent2
//
//  Cliente HTTP base: URLSession + JWT + envelope { data, error }.
//

import Foundation
import Observation

enum APIError: LocalizedError {
    case servidorNoConfigurado
    case noAutenticado
    case servidor(String)
    case sinConexion(String)
    case respuestaInvalida

    var errorDescription: String? {
        switch self {
        case .servidorNoConfigurado:
            return "Configura la URL del servidor en Ajustes"
        case .noAutenticado:
            return "La sesión expiró, inicia sesión de nuevo"
        case .servidor(let mensaje):
            return mensaje
        case .sinConexion(let detalle):
            return "Sin conexión con el servidor: \(detalle)"
        case .respuestaInvalida:
            return "El servidor devolvió una respuesta inesperada"
        }
    }
}

/// Envelope estándar del backend: { "data": ..., "error": null }
private struct APIEnvelope<T: Decodable>: Decodable {
    let data: T?
    let error: String?
}

@Observable
final class APIClient {

    static let shared = APIClient()

    private(set) var token: String? {
        didSet { UserDefaults.standard.set(token, forKey: Self.claveToken) }
    }

    private(set) var usuarioActual: Usuario? {
        didSet {
            let data = usuarioActual.flatMap { try? JSONEncoder().encode($0) }
            UserDefaults.standard.set(data, forKey: Self.claveUsuario)
        }
    }

    var sesionActiva: Bool { token != nil }

    private static let claveToken = "api.token"
    private static let claveUsuario = "api.usuario"

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession

    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        session = URLSession(configuration: config)

        token = UserDefaults.standard.string(forKey: Self.claveToken)
        if let data = UserDefaults.standard.data(forKey: Self.claveUsuario) {
            usuarioActual = try? JSONDecoder().decode(Usuario.self, from: data)
        }
    }

    // MARK: - Sesión

    func login(username: String, password: String) async throws {
        let respuesta: LoginResponse = try await post(
            "auth/login",
            body: CredencialesLogin(username: username, password: password),
            autenticado: false
        )
        token = respuesta.token
        usuarioActual = respuesta.usuario
    }

    func logout() {
        token = nil
        usuarioActual = nil
    }

    // MARK: - Métodos HTTP

    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        try await request(method: "GET", path: path, query: query, body: Optional<Int>.none)
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B, autenticado: Bool = true) async throws -> T {
        try await request(method: "POST", path: path, body: body, autenticado: autenticado)
    }

    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await request(method: "PUT", path: path, body: body)
    }

    func delete(_ path: String) async throws {
        let _: Bool = try await request(method: "DELETE", path: path, body: Optional<Int>.none)
    }

    /// Descarga un archivo (ej. export .xlsx) a un archivo temporal y retorna su URL local.
    func descargarArchivo(_ path: String, query: [URLQueryItem] = [], nombre: String) async throws -> URL {
        let request = try construirRequest(method: "GET", path: path, query: query, bodyData: nil, autenticado: true)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.respuestaInvalida }
            guard http.statusCode == 200 else {
                throw APIError.servidor(mensajeDeError(en: data) ?? "Error \(http.statusCode)")
            }
            let destino = FileManager.default.temporaryDirectory.appendingPathComponent(nombre)
            try? FileManager.default.removeItem(at: destino)
            try data.write(to: destino)
            return destino
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.sinConexion(error.localizedDescription)
        }
    }

    // MARK: - Implementación

    private func request<T: Decodable, B: Encodable>(
        method: String,
        path: String,
        query: [URLQueryItem] = [],
        body: B?,
        autenticado: Bool = true
    ) async throws -> T {
        let bodyData = try body.map { try encoder.encode($0) }
        let urlRequest = try construirRequest(
            method: method, path: path, query: query, bodyData: bodyData, autenticado: autenticado
        )

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.sinConexion(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.respuestaInvalida }

        if http.statusCode == 401 && autenticado {
            logout()
            throw APIError.noAutenticado
        }

        let envelope: APIEnvelope<T>
        do {
            envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
        } catch {
            throw APIError.respuestaInvalida
        }

        if let error = envelope.error {
            throw APIError.servidor(error)
        }
        guard let resultado = envelope.data else { throw APIError.respuestaInvalida }
        return resultado
    }

    private func construirRequest(
        method: String,
        path: String,
        query: [URLQueryItem],
        bodyData: Data?,
        autenticado: Bool
    ) throws -> URLRequest {
        guard let base = ServerConfig.shared.baseURL else { throw APIError.servidorNoConfigurado }

        var components = URLComponents(
            url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false
        )
        if !query.isEmpty { components?.queryItems = query }
        guard let url = components?.url else { throw APIError.servidorNoConfigurado }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let bodyData {
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if autenticado {
            guard let token else { throw APIError.noAutenticado }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func mensajeDeError(en data: Data) -> String? {
        struct SoloError: Decodable { let error: String? }
        return (try? decoder.decode(SoloError.self, from: data))?.error
    }
}

private struct CredencialesLogin: Encodable {
    let username: String
    let password: String
}
