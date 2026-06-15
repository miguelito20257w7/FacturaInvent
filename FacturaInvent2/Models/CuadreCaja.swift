//
//  CuadreCaja.swift
//  FacturaInvent2
//

import Foundation

enum Jornada: String, Codable, CaseIterable, Identifiable {
    case manana = "MAÑANA"
    case tarde = "TARDE"
    case todoElDia = "TODO EL DIA"

    var id: String { rawValue }
}

/// Denominaciones de billetes y monedas en COP, de mayor a menor.
enum Denominacion: Int, CaseIterable, Identifiable {
    case b20000 = 20000
    case b10000 = 10000
    case b5000 = 5000
    case b2000 = 2000
    case b1000 = 1000
    case m500 = 500
    case m200 = 200
    case m100 = 100
    case m50 = 50

    var id: Int { rawValue }
    var esBillete: Bool { rawValue >= 1000 }
}

/// Cuadre registrado, tal como lo devuelve la API.
struct CuadreCaja: Codable, Identifiable, Hashable {
    let id: Int
    let numeroTurno: Int
    let fecha: String        // "2026-06-09" (ISO 8601)
    let hora: String         // "13:35:00"
    let usuarioId: Int?
    let usuarioNombre: String?
    let jornada: String

    let ventasNetas: Int
    let entregas: Int
    let tarjetas: Int
    let bonos: Int
    let nequiQr: Int
    let factElectronicaCredito: Int
    let baseDelDia: Int
    let baseAnterior: Int

    let billetes20000: Int
    let billetes10000: Int
    let billetes5000: Int
    let billetes2000: Int
    let billetes1000: Int
    let monedas500: Int
    let monedas200: Int
    let monedas100: Int
    let monedas50: Int

    let totalDenominaciones: Int
    let sobranteFaltante: Int
    let createdAt: String?

    func cantidad(de denominacion: Denominacion) -> Int {
        switch denominacion {
        case .b20000: return billetes20000
        case .b10000: return billetes10000
        case .b5000: return billetes5000
        case .b2000: return billetes2000
        case .b1000: return billetes1000
        case .m500: return monedas500
        case .m200: return monedas200
        case .m100: return monedas100
        case .m50: return monedas50
        }
    }
}

/// Payload para registrar un cuadre. Codable completo para poder
/// persistirlo en la cola offline y reenviarlo después.
struct CuadreCajaNuevo: Codable {
    var numeroTurno: Int?
    var fecha: String
    var hora: String
    var jornada: String

    var ventasNetas: Int = 0
    var entregas: Int = 0
    var tarjetas: Int = 0
    var bonos: Int = 0
    var nequiQr: Int = 0
    var factElectronicaCredito: Int = 0
    var baseDelDia: Int = 0
    var baseAnterior: Int?

    var billetes20000: Int = 0
    var billetes10000: Int = 0
    var billetes5000: Int = 0
    var billetes2000: Int = 0
    var billetes1000: Int = 0
    var monedas500: Int = 0
    var monedas200: Int = 0
    var monedas100: Int = 0
    var monedas50: Int = 0
}

struct NuevoTurno: Codable {
    let numeroTurno: Int
    let baseAnterior: Int
}

// MARK: - Formato de pesos colombianos

extension Int {
    /// "$ 1.234.567" — los valores monetarios son COP sin decimales.
    var pesos: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.usesGroupingSeparator = true
        let numero = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "$ " + numero
    }
}
