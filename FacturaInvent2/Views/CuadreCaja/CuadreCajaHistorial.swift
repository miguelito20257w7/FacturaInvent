//
//  CuadreCajaHistorial.swift
//  FacturaInvent2
//
//  Historial de cuadres para auditoría: filtrable por fecha y usuario,
//  exportable a Excel (requisito en Mac, disponible también en iOS).
//

import SwiftUI
import Observation

@Observable
@MainActor
final class CuadreCajaHistorialModel {
    var cuadres: [CuadreCaja] = []
    var usuarios: [Usuario] = []
    var cargando = false
    var error: String?

    var filtrarPorFecha = false
    var fechaDesde = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var fechaHasta = Date()
    var usuarioFiltro: String = ""

    var hayFiltros: Bool { filtrarPorFecha || !usuarioFiltro.isEmpty }

    var filtros: CuadreCajaEndpoint.Filtros {
        CuadreCajaEndpoint.Filtros(
            fechaDesde: filtrarPorFecha ? fechaDesde : nil,
            fechaHasta: filtrarPorFecha ? fechaHasta : nil,
            usuario: usuarioFiltro.isEmpty ? nil : usuarioFiltro
        )
    }

    func cargar() async {
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            await ColaCuadresOffline.shared.sincronizar()
            cuadres = try await CuadreCajaEndpoint.historial(filtros: filtros)
            if usuarios.isEmpty {
                usuarios = (try? await AuthEndpoint.usuarios()) ?? []
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

/// Wrapper Identifiable para presentar el .sheet de compartir.
struct ArchivoExportado: Identifiable {
    let id = UUID()
    let url: URL
}

struct CuadreCajaHistorial: View {
    @State private var model = CuadreCajaHistorialModel()
    @State private var mostrandoFiltros = false
    @State private var archivoExportado: ArchivoExportado?
    @State private var errorExport: String?
    @State private var exportando = false

    var body: some View {
        List {
            if ColaCuadresOffline.shared.pendientes.count > 0 {
                Section {
                    Label(
                        "\(ColaCuadresOffline.shared.pendientes.count) cuadre(s) pendientes por sincronizar",
                        systemImage: "clock.arrow.2.circlepath"
                    )
                    .foregroundStyle(.orange)
                }
            }
            if model.hayFiltros {
                Section {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        Text(descripcionFiltros)
                        Spacer()
                        Button("Quitar") {
                            model.filtrarPorFecha = false
                            model.usuarioFiltro = ""
                            Task { await model.cargar() }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            ForEach(model.cuadres) { cuadre in
                NavigationLink(value: cuadre) {
                    FilaCuadre(cuadre: cuadre)
                }
            }
        }
        .navigationTitle("Historial")
        .navigationDestination(for: CuadreCaja.self) { cuadre in
            CuadreCajaDetalle(cuadre: cuadre)
        }
        .task { await model.cargar() }
        .refreshable { await model.cargar() }
        .overlay {
            if model.cuadres.isEmpty && model.cargando {
                ProgressView("Cargando historial…")
            } else if model.cuadres.isEmpty, let error = model.error {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else if model.cuadres.isEmpty {
                ContentUnavailableView(
                    "Sin cuadres", systemImage: "tray",
                    description: Text("Los cuadres registrados aparecerán aquí")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    mostrandoFiltros = true
                } label: {
                    Label("Filtros", systemImage: model.hayFiltros
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await exportar() }
                } label: {
                    if exportando {
                        ProgressView()
                    } else {
                        Label("Exportar a Excel", systemImage: "tablecells")
                    }
                }
                .disabled(exportando)
            }
        }
        .sheet(isPresented: $mostrandoFiltros) {
            HojaFiltros(model: model)
        }
        .sheet(item: $archivoExportado) { archivo in
            HojaCompartirArchivo(url: archivo.url, titulo: "Historial en Excel")
        }
        .alert("Error al exportar", isPresented: .init(
            get: { errorExport != nil },
            set: { if !$0 { errorExport = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorExport ?? "")
        }
    }

    private var descripcionFiltros: String {
        var partes: [String] = []
        if model.filtrarPorFecha {
            partes.append("\(model.fechaDesde.formatted(date: .abbreviated, time: .omitted)) – \(model.fechaHasta.formatted(date: .abbreviated, time: .omitted))")
        }
        if !model.usuarioFiltro.isEmpty {
            partes.append(model.usuarioFiltro)
        }
        return partes.joined(separator: " · ")
    }

    private func exportar() async {
        exportando = true
        defer { exportando = false }
        do {
            let url = try await CuadreCajaEndpoint.exportarExcel(filtros: model.filtros)
            archivoExportado = ArchivoExportado(url: url)
        } catch {
            errorExport = error.localizedDescription
        }
    }
}

// MARK: - Hoja de filtros

struct HojaFiltros: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: CuadreCajaHistorialModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Fecha") {
                    Toggle("Filtrar por fecha", isOn: $model.filtrarPorFecha)
                    if model.filtrarPorFecha {
                        DatePicker("Desde", selection: $model.fechaDesde, displayedComponents: .date)
                        DatePicker("Hasta", selection: $model.fechaHasta, displayedComponents: .date)
                    }
                }
                Section("Usuario") {
                    Picker("Cajero", selection: $model.usuarioFiltro) {
                        Text("Todos").tag("")
                        ForEach(model.usuarios) { usuario in
                            Text(usuario.nombre).tag(usuario.nombre)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        dismiss()
                        Task { await model.cargar() }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Fila del historial

struct FilaCuadre: View {
    let cuadre: CuadreCaja

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Turno \(cuadre.numeroTurno)")
                    .font(.headline)
                Text("\(cuadre.usuarioNombre ?? "—") · \(cuadre.jornada)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(cuadre.fecha)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Text(cuadre.sobranteFaltante.pesos)
                .bold()
                .monospacedDigit()
                .foregroundStyle(cuadre.sobranteFaltante >= 0 ? .green : .red)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Detalle de un cuadre

struct CuadreCajaDetalle: View {
    let cuadre: CuadreCaja

    var body: some View {
        Form {
            Section("Turno") {
                FilaDato("Turno", "\(cuadre.numeroTurno)")
                FilaDato("Fecha", cuadre.fecha)
                FilaDato("Hora", cuadre.hora)
                FilaDato("Usuario", cuadre.usuarioNombre ?? "—")
                FilaDato("Jornada", cuadre.jornada)
            }
            Section("Valores") {
                FilaDato("Ventas netas", cuadre.ventasNetas.pesos)
                FilaDato("Entregas", cuadre.entregas.pesos)
                FilaDato("Tarjetas", cuadre.tarjetas.pesos)
                FilaDato("Bonos", cuadre.bonos.pesos)
                FilaDato("Nequi o QR", cuadre.nequiQr.pesos)
                FilaDato("Fact. crédito", cuadre.factElectronicaCredito.pesos)
                FilaDato("Base del día", cuadre.baseDelDia.pesos)
                FilaDato("Base anterior", cuadre.baseAnterior.pesos)
            }
            Section("Denominaciones") {
                ForEach(Denominacion.allCases) { denominacion in
                    let cantidad = cuadre.cantidad(de: denominacion)
                    if cantidad > 0 {
                        HStack {
                            Text(denominacion.rawValue.pesos).monospacedDigit()
                            Spacer()
                            Text("× \(cantidad)")
                            Text((cantidad * denominacion.rawValue).pesos)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                                .frame(width: 110, alignment: .trailing)
                        }
                    }
                }
                FilaDato("Total base", cuadre.totalDenominaciones.pesos)
            }
            Section {
                VStack(spacing: 4) {
                    Text(cuadre.sobranteFaltante >= 0 ? "SOBRANTE" : "FALTANTE")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(cuadre.sobranteFaltante.pesos)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(cuadre.sobranteFaltante >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Turno \(cuadre.numeroTurno)")
    }
}

struct FilaDato: View {
    let titulo: String
    let valor: String

    init(_ titulo: String, _ valor: String) {
        self.titulo = titulo
        self.valor = valor
    }

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text(valor).foregroundStyle(.secondary).monospacedDigit()
        }
    }
}

// MARK: - Compartir archivo exportado

struct HojaCompartirArchivo: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    let titulo: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tablecells")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text(titulo)
                .font(.title3)
            Text(url.lastPathComponent)
                .font(.caption)
                .foregroundStyle(.secondary)
            ShareLink(item: url) {
                Label("Compartir / Guardar", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            Button("Listo") { dismiss() }
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack { CuadreCajaHistorial() }
}
