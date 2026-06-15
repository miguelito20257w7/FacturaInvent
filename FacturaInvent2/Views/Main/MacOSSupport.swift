//
//  MacOSSupport.swift
//  FacturaInvent2
//
//  Soporte exclusivo para Mac Catalyst: sidebar y menú de la app.
//

#if targetEnvironment(macCatalyst)
import SwiftUI

// MARK: - Secciones de la barra lateral

enum SidebarItem: String, CaseIterable, Identifiable {
    case cuadre = "Cuadre de Caja"
    case historial = "Historial"
    case empresas = "Empresas"
    case crear = "Agregar factura"
    case mail = "Mail"
    case buscar = "Buscar"

    var id: String { rawValue }

    var label: String { rawValue }

    var icon: String {
        switch self {
        case .cuadre: return "dollarsign.square"
        case .historial: return "clock.arrow.circlepath"
        case .empresas: return "building.2"
        case .crear: return "plus.circle"
        case .mail: return "envelope"
        case .buscar: return "magnifyingglass"
        }
    }
}

// MARK: - FocusedValue para la selección de sidebar

struct SidebarSelectionKey: FocusedValueKey {
    typealias Value = Binding<SidebarItem?>
}

extension FocusedValues {
    var sidebarSelection: Binding<SidebarItem?>? {
        get { self[SidebarSelectionKey.self] }
        set { self[SidebarSelectionKey.self] = newValue }
    }
}

// MARK: - Menú de la app

struct AppMenuCommands: Commands {
    var appState: AppState
    @FocusedValue(\.sidebarSelection) private var sidebarSelection

    var body: some Commands {
        // Ajustes en el menú de la app (⌘,), como pide el spec para macOS.
        CommandGroup(replacing: .appSettings) {
            Button("Ajustes…") {
                appState.mostrarAjustes = true
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        CommandMenu("Navegación") {
            Button("Cuadre de Caja") { sidebarSelection?.wrappedValue = .cuadre }
                .keyboardShortcut("1", modifiers: .command)
            Button("Historial") { sidebarSelection?.wrappedValue = .historial }
                .keyboardShortcut("2", modifiers: .command)
            Button("Empresas") { sidebarSelection?.wrappedValue = .empresas }
                .keyboardShortcut("3", modifiers: .command)
            Button("Agregar factura") { sidebarSelection?.wrappedValue = .crear }
                .keyboardShortcut("4", modifiers: .command)
            Button("Mail") { sidebarSelection?.wrappedValue = .mail }
                .keyboardShortcut("5", modifiers: .command)
            Button("Buscar") { sidebarSelection?.wrappedValue = .buscar }
                .keyboardShortcut("6", modifiers: .command)
        }
    }
}
#endif // targetEnvironment(macCatalyst)
