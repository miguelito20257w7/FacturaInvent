//
//  ServerConfig.swift
//  FacturaInvent2
//
//  URL del servidor configurable en caliente. Se persiste en UserDefaults
//  y todas las peticiones la leen al momento de ejecutarse, así que cambiarla
//  en Ajustes surte efecto sin reiniciar la app.
//

import Foundation
import Observation

@Observable
final class ServerConfig {

    static let shared = ServerConfig()

    enum EstadoConexion: Equatable {
        case desconocido
        case probando
        case conectado
        case sinConexion(String)
    }

    /// URL del servidor, ej. "http://192.168.1.50:8000" o "http://localhost:8000"
    var urlServidor: String {
        didSet { UserDefaults.standard.set(urlServidor, forKey: Self.claveURL) }
    }

    /// true cuando el usuario ya pasó el onboarding de configuración
    var configurado: Bool {
        didSet { UserDefaults.standard.set(configurado, forKey: Self.claveConfigurado) }
    }

    var estado: EstadoConexion = .desconocido

    private static let claveURL = "servidor.url"
    private static let claveConfigurado = "servidor.configurado"

    private init() {
        urlServidor = UserDefaults.standard.string(forKey: Self.claveURL) ?? "http://localhost:8000"
        configurado = UserDefaults.standard.bool(forKey: Self.claveConfigurado)
    }

    var baseURL: URL? {
        var texto = urlServidor.trimmingCharacters(in: .whitespacesAndNewlines)
        while texto.hasSuffix("/") { texto.removeLast() }
        guard !texto.isEmpty else { return nil }
        if !texto.lowercased().hasPrefix("http://") && !texto.lowercased().hasPrefix("https://") {
            texto = "http://" + texto
        }
        return URL(string: texto)
    }

    /// Hace ping a GET /health (sin auth). Actualiza `estado` y retorna si respondió.
    @discardableResult
    func probarConexion() async -> Bool {
        guard let base = baseURL else {
            estado = .sinConexion("URL inválida")
            return false
        }
        estado = .probando
        var request = URLRequest(url: base.appendingPathComponent("health"))
        request.timeoutInterval = 5
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                estado = .sinConexion("El servidor respondió con un error")
                return false
            }
            estado = .conectado
            return true
        } catch {
            estado = .sinConexion(error.localizedDescription)
            return false
        }
    }
}
