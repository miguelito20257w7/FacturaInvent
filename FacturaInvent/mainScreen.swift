import SwiftUI
import SwiftData

struct MainScreen: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0  // ← AGREGADO

    #if targetEnvironment(macCatalyst)
    @State private var sidebarSelection: SidebarItem? = .empresas
    #endif

    var body: some View {
        #if targetEnvironment(macCatalyst)
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                ForEach(SidebarItem.allCases) { item in
                    Label(item.label, systemImage: item.icon)
                        .tag(item)
                }
            }
            .navigationTitle("FacturaInvent")
            .navigationSplitViewColumnWidth(min: 180, ideal: 250, max: 300)
        } detail: {
            switch sidebarSelection ?? .empresas {
            case .empresas:
                EmpresasTab(selectedTab: $selectedTab)  // ← CORREGIDO
            case .crear:
                CrearTab(selectedTab: $selectedTab)     // ← CORREGIDO
            case .exportar:
                ExportarTab(selectedTab: $selectedTab)  // ← CORREGIDO
            case .buscar:
                BuscarTab(selectedTab: $selectedTab)    // ← CORREGIDO
            }
        }
        .focusedValue(\.sidebarSelection, $sidebarSelection)
        .macWindowResizable(minSize: CGSize(width: 750, height: 550))
        #else
        TabView(selection: $selectedTab) {  // ← selection agregado
            EmpresasTab(selectedTab: $selectedTab)
                .tabItem { Label("Businesses", systemImage: "building.2") }
                .tag(0)

            CrearTab(selectedTab: $selectedTab)
                .tabItem { Label("Create", systemImage: "plus.circle") }
                .tag(1)

            ExportarTab(selectedTab: $selectedTab)
                .tabItem { Label("Export", systemImage: "doc.text") }
                .tag(2)

            BuscarTab(selectedTab: $selectedTab)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(3)
        }
        #endif
    }
}

// MARK: - Empresas

struct EmpresasTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query var empresas: [Empresa]
    @Binding var selectedTab: Int  // ← AGREGADO

    private var sqliteURL: URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("default.store")
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(empresas) { empresa in
                    NavigationLink(destination: EmpresaDetalle(empresa: empresa, selectedTab: $selectedTab)) {  // ← CORREGIDO
                        HStack {
                            Text(empresa.nombre)
                            Spacer()
                            Text("NIT: \(empresa.nit)")
                        }
                    }
                }.sheet(isPresented: Bindable(appState).mostrarAgregarBaseDeDatos) {
                    ImportarBaseDeDatos()
                }
            }
            .navigationTitle("Businesses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = sqliteURL {
                        ShareLink(
                            item: url,
                            preview: SharePreview(
                                "FacturaInvent.store",
                                icon: Image(systemName: "cylinder")
                            )
                        )
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.mostrarAgregarBaseDeDatos = true
                    } label: {
                        Image(systemName: "doc")
                    }
                }
                #if !targetEnvironment(macCatalyst)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                #endif
            }
            .overlay {
                if empresas.isEmpty {
                    ContentUnavailableView(
                        "No businesses",
                        systemImage: "building.2",
                        description: Text("Add a business to start")
                    )
                }
            }
        }
    }
}

// MARK: - Crear

struct CrearTab: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedTab: Int  // ← AGREGADO

    var body: some View {
        NavigationStack {
            AgregarXML(selectedTab: $selectedTab)  // ← CORREGIDO
                .environment(appState)
                .navigationTitle("Create")
        }
    }
}

// MARK: - Exportar

struct ExportarTab: View {
    @Binding var selectedTab: Int  // ← AGREGADO

    var body: some View {
        NavigationStack {
            ExportarExcelView(selectedTab: $selectedTab)  // ← CORREGIDO
                .navigationTitle("Export")
        }
    }
}

// MARK: - Buscar

struct BuscarTab: View {
    @Binding var selectedTab: Int  // ← AGREGADO

    var body: some View {
        NavigationStack {
            Buscador(selectedTab: $selectedTab)  // ← CORREGIDO
        }
    }
}

#Preview {
    BuscarTab(selectedTab: .constant(3))
}
