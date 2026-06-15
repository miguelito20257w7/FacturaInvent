//
//  EmpresasView.swift
//  FacturaInvent2
//

import SwiftUI

struct EmpresasView: View {
    @State private var empresas: [Empresa] = []
    @State private var cargando = false
    @State private var error: String?
    @State private var mostrandoNueva = false

    var body: some View {
        List {
            ForEach(empresas) { empresa in
                NavigationLink(value: empresa) {
                    HStack {
                        Text(empresa.nombre)
                        Spacer()
                        Text("NIT: \(empresa.nit)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                Task { await eliminar(offsets) }
            }
        }
        .navigationTitle("Empresas")
        .navigationDestination(for: Empresa.self) { empresa in
            EmpresaDetalleView(empresa: empresa)
        }
        .task { await cargar() }
        .refreshable { await cargar() }
        .overlay {
            if empresas.isEmpty && cargando {
                ProgressView("Cargando…")
            } else if empresas.isEmpty, let error {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else if empresas.isEmpty {
                ContentUnavailableView(
                    "Sin empresas", systemImage: "building.2",
                    description: Text("Agrega una empresa o importa una factura XML")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    mostrandoNueva = true
                } label: {
                    Label("Agregar empresa", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrandoNueva) {
            EmpresaFormSheet { nombre, nit in
                _ = try await EmpresasEndpoint.crear(nombre: nombre, nit: nit)
                await cargar()
            }
        }
    }

    private func cargar() async {
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            empresas = try await EmpresasEndpoint.listar()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func eliminar(_ offsets: IndexSet) async {
        for index in offsets {
            let empresa = empresas[index]
            do {
                try await EmpresasEndpoint.eliminar(id: empresa.id)
            } catch {
                self.error = error.localizedDescription
                return
            }
        }
        await cargar()
    }
}

// MARK: - Formulario crear/editar empresa

struct EmpresaFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    var empresa: Empresa? = nil
    let onGuardar: (String, String) async throws -> Void

    @State private var nombre = ""
    @State private var nit = ""
    @State private var error: String?
    @State private var guardando = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("NIT", text: $nit)
                if let error {
                    Text(error).foregroundStyle(.red).font(.callout)
                }
            }
            .navigationTitle(empresa == nil ? "Nueva empresa" : "Editar empresa")
            #if !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task { await guardar() }
                    }
                    .disabled(nombre.isEmpty || nit.isEmpty || guardando)
                }
            }
            .onAppear {
                if let empresa {
                    nombre = empresa.nombre
                    nit = empresa.nit
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func guardar() async {
        guardando = true
        defer { guardando = false }
        do {
            try await onGuardar(nombre, nit)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { EmpresasView() }
}
