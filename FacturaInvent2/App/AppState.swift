//
//  AppState.swift
//  FacturaInvent2
//

import Foundation
import Observation

@Observable
final class AppState {
    /// Abre la hoja de Ajustes (toolbar en iOS, menú de la app en macOS).
    var mostrarAjustes = false
}

extension Notification.Name {
    /// Un XML descargado desde Gmail listo para importar en la pestaña Crear.
    static let importarFacturaDesdeCorreo = Notification.Name("importarFacturaDesdeCorreo")
}
