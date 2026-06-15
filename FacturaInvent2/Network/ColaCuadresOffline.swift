//
//  ColaCuadresOffline.swift
//  FacturaInvent2
//
//  Offline-first para el cuadre de caja: si no hay conexión con el servidor
//  al guardar, el cuadre queda encolado en disco y se sincroniza cuando
//  vuelve la conexión (al abrir la app, al refrescar, o manualmente desde
//  Ajustes).
//

import Foundation
import Observation

struct CuadrePendiente: Codable, Identifiable {
    let id: UUID
    let creadoEn: Date
    let cuadre: CuadreCajaNuevo
}

@Observable
final class ColaCuadresOffline {

    static let shared = ColaCuadresOffline()

    private(set) var pendientes: [CuadrePendiente] = []
    private(set) var sincronizando = false

    private var archivoURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("cuadres-pendientes.json")
    }

    private init() {
        cargar()
    }

    func encolar(_ cuadre: CuadreCajaNuevo) {
        pendientes.append(CuadrePendiente(id: UUID(), creadoEn: Date(), cuadre: cuadre))
        guardar()
    }

    func descartar(_ pendiente: CuadrePendiente) {
        pendientes.removeAll { $0.id == pendiente.id }
        guardar()
    }

    /// Envía los cuadres pendientes en orden (el más antiguo primero).
    /// Se detiene en el primer fallo de conexión; los errores de validación
    /// del servidor descartan ese cuadre para no bloquear la cola.
    @discardableResult
    func sincronizar() async -> Int {
        guard !sincronizando, !pendientes.isEmpty, APIClient.shared.sesionActiva else { return 0 }
        sincronizando = true
        defer { sincronizando = false }

        var enviados = 0
        for pendiente in pendientes.sorted(by: { $0.creadoEn < $1.creadoEn }) {
            do {
                _ = try await CuadreCajaEndpoint.crear(pendiente.cuadre)
                pendientes.removeAll { $0.id == pendiente.id }
                enviados += 1
            } catch APIError.sinConexion {
                break
            } catch APIError.noAutenticado {
                break
            } catch {
                // El servidor lo rechazó (dato inválido): lo sacamos de la cola
                // para que no bloquee a los demás.
                pendientes.removeAll { $0.id == pendiente.id }
            }
        }
        guardar()
        return enviados
    }

    // MARK: - Persistencia en disco

    private func cargar() {
        guard let data = try? Data(contentsOf: archivoURL),
              let lista = try? JSONDecoder().decode([CuadrePendiente].self, from: data) else {
            return
        }
        pendientes = lista
    }

    private func guardar() {
        guard let data = try? JSONEncoder().encode(pendientes) else { return }
        try? data.write(to: archivoURL, options: .atomic)
    }
}
