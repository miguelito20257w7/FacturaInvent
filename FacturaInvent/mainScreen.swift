import SwiftUI
import SwiftData

struct MainScreen: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0
    @State private var xmlURLParaImportar: URL? = nil
    @State private var xmlURLParaExportar: URL? = nil

    #if targetEnvironment(macCatalyst)
    @State private var sidebarSelection: SidebarItem? = .empresas
    #endif

    var body: some View {
        contenido
            .onReceive(NotificationCenter.default.publisher(for: .importarFacturaDesdeCorreo)) { notif in
                guard let url = notif.object as? URL else { return }
                xmlURLParaImportar = url
                #if targetEnvironment(macCatalyst)
                sidebarSelection = .crear
                #else
                selectedTab = 1
                #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: .exportarFacturaDesdeCorreo)) { notif in
                guard let url = notif.object as? URL else { return }
                xmlURLParaExportar = url
                #if targetEnvironment(macCatalyst)
                sidebarSelection = .exportar
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
            .navigationTitle("FacturaInvent")
            .navigationSplitViewColumnWidth(min: 180, ideal: 250, max: 300)
        } detail: {
            switch sidebarSelection ?? .empresas {
            case .empresas:
                EmpresasTab(selectedTab: $selectedTab)
            case .crear:
                CrearTab(selectedTab: $selectedTab, xmlURL: xmlURLParaImportar)
            case .mailView:
                mailView()
            case .exportar:
                ExportarTab(selectedTab: $selectedTab, xmlURL: xmlURLParaExportar)
            case .buscar:
                BuscarTab(selectedTab: $selectedTab)
            }
        }
        .focusedValue(\.sidebarSelection, $sidebarSelection)
        .macWindowResizable(minSize: CGSize(width: 750, height: 550))
        #else
        TabView(selection: $selectedTab) {
            Tab("Businesses", systemImage: "building.2", value: 0) {
                EmpresasTab(selectedTab: $selectedTab)
            }
            Tab("Create", systemImage: "plus.circle", value: 1) {
                CrearTab(selectedTab: $selectedTab, xmlURL: xmlURLParaImportar)
            }
            Tab("Mail", systemImage: "envelope", value: 2) {
                mailView()
            }
            Tab("Export", systemImage: "doc.text", value: 3) {
                ExportarTab(selectedTab: $selectedTab, xmlURL: xmlURLParaExportar)
            }
            Tab(value: 4, role: .search) {
                BuscarTab(selectedTab: $selectedTab)
            }
        }
        #endif
    }
}

// MARK: - Empresas

private struct ExportableStore: Identifiable {
    let id = UUID()
    let url: URL
}

struct EmpresasTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query var empresas: [Empresa]
    @Binding var selectedTab: Int
    @State private var exportableStore: ExportableStore? = nil
    @State private var exportError = false
    @State private var exportErrorMensaje = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(empresas) { empresa in
                    NavigationLink(destination: EmpresaDetalle(empresa: empresa, selectedTab: $selectedTab)) {
                        HStack {
                            Text(empresa.nombre)
                            Spacer()
                            Text("NIT: \(empresa.nit)")
                        }
                    }
                }
            }
            .navigationTitle("Businesses")
            .sheet(isPresented: Bindable(appState).mostrarAgregarBaseDeDatos) {
                ImportarBaseDeDatos()
            }
            .sheet(item: $exportableStore) { item in
                VStack(spacing: 20) {
                    Image(systemName: "cylinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                    Text("Database backup ready")
                        .font(.title3)
                    ShareLink(
                        item: item.url,
                        preview: SharePreview(
                            item.url.lastPathComponent,
                            icon: Image(systemName: "cylinder")
                        )
                    ) {
                        Label("Share backup", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal)
                    Button("Done") { exportableStore = nil }
                }
                .padding()
                .presentationDetents([.medium])
            }
            .alert("Export error", isPresented: $exportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportErrorMensaje)
            }
            .onChange(of: appState.mostrarExportarDB) { _, newValue in
                guard newValue else { return }
                appState.mostrarExportarDB = false
                do {
                    let url = try exportarBackupStore(modelContext: modelContext)
                    exportableStore = ExportableStore(url: url)
                } catch {
                    exportErrorMensaje = error.localizedDescription
                    exportError = true
                }
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
    @Binding var selectedTab: Int
    var xmlURL: URL? = nil

    var body: some View {
        NavigationStack {
            AgregarXML(selectedTab: $selectedTab, xmlURLInicial: xmlURL)
                .environment(appState)
                .navigationTitle("Create")
        }
    }
}

// MARK: - Exportar

struct ExportarTab: View {
    @Binding var selectedTab: Int
    var xmlURL: URL? = nil

    var body: some View {
        NavigationStack {
            ExportarExcelView(selectedTab: $selectedTab, xmlURLInicial: xmlURL)
                .navigationTitle("Export")
        }
    }
}

// MARK: - Buscar

struct BuscarTab: View {
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            Buscador(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    BuscarTab(selectedTab: .constant(3))
}
