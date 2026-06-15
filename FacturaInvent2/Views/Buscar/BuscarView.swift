//
//  BuscarView.swift
//  FacturaInvent2
//
//  Búsqueda global de productos en todas las empresas (la hace el servidor).
//

import SwiftUI

struct BuscarView: View {
    @State private var texto = ""
    @State private var resultados: [Producto] = []
    @State private var buscando = false
    @State private var error: String?
    @State private var tareaBusqueda: Task<Void, Never>?

    var body: some View {
        List(resultados) { producto in
            FilaProducto(producto: producto)
        }
        .navigationTitle("Buscar")
        .searchable(text: $texto, prompt: "Nombre, código o código de barras")
        .onChange(of: texto) { _, nuevo in
            buscarConRetraso(nuevo)
        }
        .overlay {
            if buscando && resultados.isEmpty {
                ProgressView()
            } else if let error {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else if resultados.isEmpty && !texto.isEmpty {
                ContentUnavailableView.search(text: texto)
            } else if resultados.isEmpty {
                ContentUnavailableView(
                    "Busca en todo el inventario",
                    systemImage: "magnifyingglass",
                    description: Text("Escribe un nombre, código de factura o código de barras")
                )
            }
        }
    }

    /// Pequeño debounce para no llamar a la API en cada tecla.
    private func buscarConRetraso(_ consulta: String) {
        tareaBusqueda?.cancel()
        guard !consulta.isEmpty else {
            resultados = []
            error = nil
            return
        }
        tareaBusqueda = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await buscar(consulta)
        }
    }

    private func buscar(_ consulta: String) async {
        buscando = true
        error = nil
        defer { buscando = false }
        do {
            resultados = try await ProductosEndpoint.buscarGlobal(consulta)
        } catch is CancellationError {
            // búsqueda reemplazada por una más reciente
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { BuscarView() }
}
