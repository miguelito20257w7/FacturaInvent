//
//  ImportarBaseDeDatos.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 21/04/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SQLite3

struct ImportarBaseDeDatos: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var mostrarFilePicker = false
    @State private var importando = false
    @State private var importacionExitosa = false
    @State private var mensaje: String? = nil
    @State private var esError = false
    @State private var archivoPendiente: URL? = nil
    @State private var mostrarConfirmacion = false

    var body: some View {
        NavigationStack {
            content
        }
        .fileImporter(
            isPresented: $mostrarFilePicker,
            allowedContentTypes: [.data, UTType(filenameExtension: "store")].compactMap { $0 },
            allowsMultipleSelection: false
        ) { result in
            Task { await prepararConfirmacion(result) }
        }
        .alert("Replace all data?", isPresented: $mostrarConfirmacion, presenting: archivoPendiente) { url in
            Button("Cancel", role: .cancel) {
                archivoPendiente = nil
            }
            Button("Replace all", role: .destructive) {
                Task { await procesarArchivo(url) }
            }
        } message: { _ in
            Text("This will permanently delete every business and product before restoring the file. This action cannot be undone.")
        }
    }

    private var content: some View {
        VStack(spacing: 20) {
            Image(systemName: importacionExitosa
                  ? "checkmark.circle.fill"
                  : "tray.and.arrow.down")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundStyle(importacionExitosa ? .green : .secondary)

            Text(importacionExitosa
                 ? "Import successful!"
                 : "Choose a backup file to import (.store)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if !importacionExitosa {
                Button {
                    mostrarFilePicker = true
                } label: {
                    Label("Choose file…", systemImage: "tray.and.arrow.down")
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(importando)
            }

            if importando {
                ProgressView()
            }

            if let mensaje = mensaje {
                Text(mensaje)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(esError ? .red : .primary)
                    .padding(.horizontal)
            }

        }
        .padding()
        .navigationTitle("Import Database")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(importacionExitosa ? "Done" : "Cancel") { dismiss() }
                    .disabled(importando)
            }
        }
    }

    // MARK: - Flujo: elegir archivo → confirmar → procesar

    private func prepararConfirmacion(_ result: Result<[URL], Error>) async {
        switch result {
        case .failure(let error):
            await MainActor.run {
                mostrarError("Error al elegir el archivo: \(error.localizedDescription)")
            }
        case .success(let urls):
            guard let url = urls.first else {
                await MainActor.run { mostrarError("No se eligió ningún archivo") }
                return
            }
            await MainActor.run {
                archivoPendiente = url
                mostrarConfirmacion = true
            }
        }
    }

    @MainActor
    private func procesarArchivo(_ url: URL) async {
        guard url.startAccessingSecurityScopedResource() else {
            mostrarError("Sin permiso para acceder al archivo")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        importando = true
        mensaje = nil
        esError = false

        let ext = url.pathExtension.lowercased()

        do {
            if ext == "store" {
                let stats = try await importarDesdeStore(url: url)
                await marcarExito("Imported \(stats.empresas) businesses and \(stats.productos) products")
            } else {
                mostrarError("Unsupported file type: .\(ext). Use .store or .json")
            }
        } catch {
            mostrarError("Error: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func marcarExito(_ texto: String) async {
        mensaje = texto
        esError = false
        importando = false
        importacionExitosa = true
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        dismiss()
    }

    private func mostrarError(_ texto: String) {
        mensaje = texto
        esError = true
        importando = false
        importacionExitosa = false
    }

    // MARK: - Import .store con copia previa

    private func importarDesdeStore(url: URL) async throws -> (empresas: Int, productos: Int) {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tempDir) }

        let nombreBase = url.deletingPathExtension().lastPathComponent
        let tempStore = tempDir.appendingPathComponent("\(nombreBase).store")
        try fm.copyItem(at: url, to: tempStore)

        for sufijo in ["-wal", "-shm"] {
            let hermano = url.deletingPathExtension()
                .appendingPathExtension("store\(sufijo)")
            if fm.fileExists(atPath: hermano.path) {
                let destino = tempDir.appendingPathComponent("\(nombreBase).store\(sufijo)")
                try? fm.copyItem(at: hermano, to: destino)
            }
        }

        guard fm.fileExists(atPath: tempStore.path) else {
            throw NSError(domain: "ImportError", code: 404, userInfo: [NSLocalizedDescriptionKey: "El archivo temporal no se creó a tiempo."])
        }

        let config = ModelConfiguration(url: tempStore)
        let containerImportado = try ModelContainer(
            for: Schema([Empresa.self, Producto.self]),
            configurations: [config]
        )
        let contextoImportado = ModelContext(containerImportado)

        // Fetch directo de cada entidad (evita navegar la relación .productos,
        // que puede contener referencias colgantes a objetos ya borrados).
        let empresas = try contextoImportado.fetch(FetchDescriptor<Empresa>())
        let productos = try contextoImportado.fetch(FetchDescriptor<Producto>())

        // Borrar la base local SOLO después de leer correctamente.
        try modelContext.delete(model: Producto.self)
        try modelContext.delete(model: Empresa.self)
        try modelContext.save()

        // Mapa: id de empresa importada → nueva empresa local, para reconstruir
        // la relación producto→empresa sin recorrer la colección .productos.
        var mapaEmpresas: [PersistentIdentifier: Empresa] = [:]

        for empresaOriginal in empresas {
            let nuevaEmpresa = Empresa(
                nombre: empresaOriginal.nombre,
                nit: empresaOriginal.nit
            )
            modelContext.insert(nuevaEmpresa)
            mapaEmpresas[empresaOriginal.persistentModelID] = nuevaEmpresa
        }

        for productoOriginal in productos {
            let nuevo = Producto(
                codigoFactura: productoOriginal.codigoFactura,
                codigoBarras: productoOriginal.codigoBarras,
                nombre: productoOriginal.nombre
            )
            nuevo.codigoDeBarrasAutomatico = productoOriginal.codigoDeBarrasAutomatico
            nuevo.cantidadProductos = productoOriginal.cantidadProductos
            nuevo.precio = productoOriginal.precio
            nuevo.precioDividido = productoOriginal.precioDividido
            nuevo.vieneEnPaquetes = productoOriginal.vieneEnPaquetes
            nuevo.cantidadPaquetes = productoOriginal.cantidadPaquetes
            nuevo.codigoInterno = productoOriginal.codigoInterno
            nuevo.tieneDescuento = productoOriginal.tieneDescuento
            if let empID = productoOriginal.empresa?.persistentModelID {
                nuevo.empresa = mapaEmpresas[empID]
            }
            modelContext.insert(nuevo)
        }

        try modelContext.save()
        return (empresas.count, productos.count)
    }
}

#Preview {
    ImportarBaseDeDatos()
        .modelContainer(for: [Empresa.self, Producto.self], inMemory: true)
}

// MARK: - Export backup (store limpio sin CloudKit)

func exportarBackupStore(modelContext: ModelContext) throws -> URL {
    // Fetch directo de cada entidad (evita navegar la relación .productos,
    // que puede contener referencias colgantes a objetos ya borrados).
    let empresas = try modelContext.fetch(FetchDescriptor<Empresa>())
    let productos = try modelContext.fetch(FetchDescriptor<Producto>())

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let storeURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("facturainvent-\(formatter.string(from: Date())).store")

    if FileManager.default.fileExists(atPath: storeURL.path) {
        try? FileManager.default.removeItem(at: storeURL)
    }

    let schema = Schema([Empresa.self, Producto.self])
    let config = ModelConfiguration(url: storeURL)
    var container: ModelContainer? = try ModelContainer(for: schema, configurations: [config])
    var ctx: ModelContext? = ModelContext(container!)

    var mapaEmpresas: [PersistentIdentifier: Empresa] = [:]
    for emp in empresas {
        let newEmp = Empresa(nombre: emp.nombre, nit: emp.nit)
        ctx!.insert(newEmp)
        mapaEmpresas[emp.persistentModelID] = newEmp
    }

    for prod in productos {
        let newProd = Producto(
            codigoFactura: prod.codigoFactura,
            codigoBarras: prod.codigoBarras,
            nombre: prod.nombre
        )
        newProd.codigoDeBarrasAutomatico = prod.codigoDeBarrasAutomatico
        newProd.cantidadProductos       = prod.cantidadProductos
        newProd.precio                  = prod.precio
        newProd.precioDividido          = prod.precioDividido
        newProd.vieneEnPaquetes         = prod.vieneEnPaquetes
        newProd.cantidadPaquetes        = prod.cantidadPaquetes
        newProd.codigoInterno           = prod.codigoInterno
        newProd.tieneDescuento          = prod.tieneDescuento
        if let empID = prod.empresa?.persistentModelID {
            newProd.empresa = mapaEmpresas[empID]
        }
        ctx!.insert(newProd)
    }

    try ctx!.save()
    // Liberar el container para soltar la conexión SQLite antes de consolidar.
    ctx = nil
    container = nil

    // Fusionar el WAL en el archivo .store principal y volver a modo DELETE,
    // de modo que el .store sea autónomo (sin depender de -wal/-shm al compartir).
    consolidarStore(storeURL)

    return storeURL
}

/// Hace checkpoint del WAL y cambia el journal a DELETE, dejando un único
/// archivo .store con todos los datos (elimina los archivos -wal/-shm).
private func consolidarStore(_ url: URL) {
    var db: OpaquePointer?
    guard sqlite3_open(url.path, &db) == SQLITE_OK else {
        print("⚠️ No se pudo abrir el store para consolidar el WAL")
        return
    }
    defer { sqlite3_close(db) }
    sqlite3_exec(db, "PRAGMA wal_checkpoint(TRUNCATE);", nil, nil, nil)
    sqlite3_exec(db, "PRAGMA journal_mode=DELETE;", nil, nil, nil)
}
