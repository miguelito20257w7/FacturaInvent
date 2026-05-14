// MacOSSupport.swift
// FacturaInvent
//
// Soporte exclusivo para Mac Catalyst: sidebar, focused values y menú.

#if targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

// MARK: - Ventana redimensionable

struct WindowSizeConfigurator: UIViewRepresentable {
    var minSize: CGSize

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            guard let restrictions = view.window?.windowScene?.sizeRestrictions else { return }
            restrictions.minimumSize = minSize
            restrictions.maximumSize = CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func macWindowResizable(minSize: CGSize = CGSize(width: 750, height: 550)) -> some View {
        self.background(WindowSizeConfigurator(minSize: minSize))
    }
}

// MARK: - Sección de la barra lateral

enum SidebarItem: String, CaseIterable, Identifiable {
    case empresas = "Empresas"
    case crear    = "Agregar"
    case exportar = "Exportar"
    case buscar   = "Buscar"

    var id: String { rawValue }

    /// Clave localizable para usar en Text() y Label().
    /// Se usan las mismas claves en inglés que ya tienen traducción a español
    /// en Localizable.xcstrings (ver TabView en mainScreen.swift).
    var label: LocalizedStringKey {
        switch self {
        case .empresas: return "Businesses"
        case .crear:    return "Create"
        case .exportar: return "Export"
        case .buscar:   return "Search"
        }
    }

    var icon: String {
        switch self {
        case .empresas: return "building.2"
        case .crear:    return "plus.circle"
        case .exportar: return "doc.text"
        case .buscar:   return "magnifyingglass"
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

// MARK: - Comandos del menú de la barra de menús

struct AppMenuCommands: Commands {
    @FocusedValue(\.sidebarSelection) private var sidebarSelection

    var body: some Commands {
        CommandMenu("Navigation") {
            Button("Businesses") { sidebarSelection?.wrappedValue = .empresas }
                .keyboardShortcut("1", modifiers: .command)
            Button("Create") { sidebarSelection?.wrappedValue = .crear }
                .keyboardShortcut("2", modifiers: .command)
            Button("Export") { sidebarSelection?.wrappedValue = .exportar }
                .keyboardShortcut("3", modifiers: .command)
            Button("Search") { sidebarSelection?.wrappedValue = .buscar }
                .keyboardShortcut("4", modifiers: .command)
        }
    }
}
#endif // targetEnvironment(macCatalyst)
