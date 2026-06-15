//
//  MainScreen.swift
//  FacturaInvent2
//
//  iOS: TabView. Mac Catalyst: NavigationSplitView con sidebar.
//  El Cuadre de Caja es la sección principal de v2.
//

import SwiftUI

struct MainScreen: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0
    @State private var xmlURLParaImportar: URL? = nil

    #if targetEnvironment(macCatalyst)
    @State private var sidebarSelection: SidebarItem? = .cuadre
    #endif

    var body: some View {
        contenido
            .onReceive(NotificationCenter.default.publisher(for: .importarFacturaDesdeCorreo)) { notif in
                guard let url = notif.object as? URL else { return }
                xmlURLParaImportar = url
                #if targetEnvironment(macCatalyst)
                sidebarSelection = .crear
                #else
                selectedTab = 3
                #endif
            }
    }

    @ViewBuilder
    private var contenido: some View {
        #if targetEnvironment(macCatalyst)
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                ForEach(SidebarItem.allCases) { item in
                    Label(item.label, systemImage: item.icon)
                        .tag(item)
                }
            }
            .navigationTitle("FacturaInvent 2")
            .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 300)
        } detail: {
            switch sidebarSelection ?? .cuadre {
            case .cuadre:
                NavigationStack { CuadreCajaForm() }
            case .historial:
                NavigationStack { CuadreCajaHistorial() }
            case .empresas:
                NavigationStack { EmpresasView() }
            case .crear:
                NavigationStack { ImportarXMLView(xmlURLInicial: xmlURLParaImportar) }
            case .mail:
                MailView()
            case .buscar:
                NavigationStack { BuscarView() }
            }
        }
        .focusedValue(\.sidebarSelection, $sidebarSelection)
        #else
        TabView(selection: $selectedTab) {
            Tab("Cuadre", systemImage: "dollarsign.square", value: 0) {
                NavigationStack {
                    CuadreCajaForm()
                        .toolbarAjustes()
                }
            }
            Tab("Historial", systemImage: "clock.arrow.circlepath", value: 1) {
                NavigationStack {
                    CuadreCajaHistorial()
                        .toolbarAjustes()
                }
            }
            Tab("Empresas", systemImage: "building.2", value: 2) {
                NavigationStack {
                    EmpresasView()
                        .toolbarAjustes()
                }
            }
            Tab("Crear", systemImage: "plus.circle", value: 3) {
                NavigationStack {
                    ImportarXMLView(xmlURLInicial: xmlURLParaImportar)
                        .toolbarAjustes()
                }
            }
            Tab("Mail", systemImage: "envelope", value: 4) {
                MailView()
            }
            Tab(value: 5, role: .search) {
                NavigationStack { BuscarView() }
            }
        }
        #endif
    }
}

// MARK: - Botón de ajustes en la toolbar (iOS)

private struct ToolbarAjustes: ViewModifier {
    @Environment(AppState.self) private var appState

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    appState.mostrarAjustes = true
                } label: {
                    Label("Ajustes", systemImage: "gearshape")
                }
            }
        }
    }
}

extension View {
    func toolbarAjustes() -> some View {
        modifier(ToolbarAjustes())
    }
}

#Preview {
    MainScreen()
        .environment(AppState())
}
