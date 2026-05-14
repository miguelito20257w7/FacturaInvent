//
//  agregarXML.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//

import SwiftData
import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Modelo de conflicto

struct ProductoConflicto: Identifiable {
    let id = UUID()
    let productoEnDB: Producto
    let datosNuevos: ProductoImport
}

// MARK: - Vista principal

struct AgregarXML: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var productosParaImportar: [ProductoImport] = []
    @State private var productosConflicto: [ProductoConflicto] = []
    @State private var empresaActual: Empresa? = nil
    @State private var mostrarFilePicker = false
    @State private var mostrarExito = false
    @State private var productosGuardados = 0
    @Binding var selectedTab: Int

    private var hayProductos: Bool {
        !productosParaImportar.isEmpty || !productosConflicto.isEmpty
    }

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            if mostrarExito {
                pantallaExito
            } else if !hayProductos {
                pantallaInicial
            } else {
                pantallaRevision
            }
        }
        .alert(isPresented: $appState.showCancelButton) {
            Alert(
                title: Text("Are you sure you want to cancel?"),
                message: Text("All the data will be lost"),
                primaryButton: .cancel(Text("Back")),
                secondaryButton: .destructive(Text("Cancel")) {
                    // Limpiamos todo y volvemos a la pantalla inicial
                    productosParaImportar = []
                    productosConflicto = []
                    empresaActual = nil
                }
            )
        }
        .onKeyPress(.escape) {
            appState.showCancelButton = true
            return .handled
        }
    }

    // MARK: - Subvistas

    private var pantallaInicial: some View {
        VStack {
            Text("Add a business and its products here")
            Button {
                mostrarFilePicker = true
            } label: {
                Label("Add XML", systemImage: "doc.text")
            }.buttonStyle(.glassProminent)
        }
        .navigationTitle("Import Business")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { selectedTab = 0 }
            }
        }
        .fileImporter(
            isPresented: $mostrarFilePicker,
            allowedContentTypes: [UTType.xml],
            onCompletion: manejarArchivoXML
        )
    }

    private var pantallaRevision: some View {
        List {
            seccionNuevos
            seccionExistentes
        }
        .navigationTitle("Review Products")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    appState.showCancelButton = true
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    guardarProductosNuevos()
                }
            }
        }
    }

    private var pantallaExito: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Import successful!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(productosGuardados) product\(productosGuardados == 1 ? "" : "s") imported successfully")
                    .foregroundStyle(.secondary)

                if let empresa = empresaActual {
                    Text("Business: \(empresa.nombre)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            NavigationLink {
                       if let empresa = empresaActual {
                           EmpresaDetalle(empresa: empresa, selectedTab: $selectedTab)
                       }
                   } label: {
                Label("Done", systemImage: "arrow.right.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)

            Button {
                // Reiniciamos todo para importar otro XML
                productosParaImportar = []
                productosConflicto = []
                empresaActual = nil
                mostrarExito = false
                productosGuardados = 0
            } label: {
                Label("Import another XML", systemImage: "doc.text.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Success")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    selectedTab = 0
                    // Reiniciamos todo para importar otro XML
                    productosParaImportar = []
                    productosConflicto = []
                    empresaActual = nil
                    mostrarExito = false
                    productosGuardados = 0
                }
            }
        }
    }

    // MARK: - Secciones

    @ViewBuilder
    private var seccionNuevos: some View {
        if !productosParaImportar.isEmpty {
            Section("New products (\(productosParaImportar.count))") {
                ForEach(productosParaImportar.indices, id: \.self) { index in
                    if index < productosParaImportar.count {
                        filaProductoNuevo(index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var seccionExistentes: some View {
        if !productosConflicto.isEmpty {
            Section("Existing products (\(productosConflicto.count))") {
                ForEach(productosConflicto.indices, id: \.self) { index in
                    if index < productosConflicto.count {
                        filaConflicto(index: index)
                    }
                }
            }
        }
    }

    private func filaProductoNuevo(index: Int) -> some View {
        let p = productosParaImportar[index]
        let binding = Binding<ProductoImport>(
            get: {
                guard index < productosParaImportar.count else {
                    return ProductoImport(
                        codigo: "", codigoBarras: "", nombre: "",
                        cantidad: "", precioSinIVA: "",
                        vieneEnPaquetes: false, cantidadPaquetes: 1,
                        codigoBarrasAutomatico: false, codigoInterno: "",
                        tieneDescuento: false, porcentajeDescuento: 0.0
                    )
                }
                return productosParaImportar[index]
            },
            set: { newVal in
                guard index < productosParaImportar.count else { return }
                productosParaImportar[index] = newVal
            }
        )
        return NavigationLink {
            PreviewProducto(
                producto: binding,
                onEliminar: { productosParaImportar.remove(at: index) }
            )
        } label: {
            VStack(alignment: .leading) {
                Text(p.nombre)
                Text(verbatim: p.codigo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !p.codigoInterno.isEmpty {
                    Text("Intern Code: \(p.codigoInterno)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func filaConflicto(index: Int) -> some View {
        let conflicto = productosConflicto[index]
        let db = conflicto.productoEnDB
        let nombreCambio = db.nombre != conflicto.datosNuevos.nombre

        return NavigationLink {
            DetalleProducto(producto: db)
        } label: {
            VStack(alignment: .leading) {
                Text(db.nombre)
                    .fontWeight(.medium)
                if nombreCambio {
                    Text("XML: \(conflicto.datosNuevos.nombre)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Text(verbatim: db.codigoFactura)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Parseo XML

    private func manejarArchivoXML(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                print("Sin permiso para acceder al archivo")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let contenido = try String(contentsOf: url, encoding: .utf8)

                guard let inicio = contenido.range(of: "<![CDATA["),
                      let fin   = contenido.range(of: "]]>") else {
                    print("There was an error parsing the XML (no CDATA tag)")
                    return
                }

                let factura = String(contenido[inicio.upperBound..<fin.lowerBound])
                guard let data = factura.data(using: .utf8) else { return }

                let xmlparser = XMLParser(data: data)
                let delegado  = XMLFacturaParser()
                xmlparser.delegate = delegado
                xmlparser.shouldProcessNamespaces = true
                xmlparser.parse()

                let codigosBarrasCount  = Dictionary(grouping: delegado.productos, by: { $0.codigoBarras })
                let codigosFacturaCount = Dictionary(grouping: delegado.productos, by: { $0.codigo })

                let nitBuscado = delegado.nit
                let descriptor = FetchDescriptor<Empresa>(
                    predicate: #Predicate { empresa in empresa.nit == nitBuscado }
                )

                let empresasExistentes = try modelContext.fetch(descriptor)

                if let empresaExistente = empresasExistentes.first {
                    print("Se encontró la empresa: \(empresaExistente.nombre)")
                    empresaActual = empresaExistente
                } else {
                    let nuevaEmpresa = Empresa(nombre: delegado.nombreEmpresa, nit: delegado.nit)
                    modelContext.insert(nuevaEmpresa)
                    print("Se creó una nueva empresa: \(nuevaEmpresa.nombre)")
                    empresaActual = nuevaEmpresa
                }

                let productosEmpresa = empresaActual?.productos ?? []
                print("Productos encontrados en XML: \(delegado.productos.count)")

                for productoData in delegado.productos {
                    let codigoBuscado  = productoData.codigo
                    let barrasBuscadas = productoData.codigoBarras

                    print("Empresa: \(delegado.nombreEmpresa) | Nit: \(delegado.nit)")
                    print("codigo: \(productoData.codigo) | Barras: \(productoData.codigoBarras) | Nombre: \(productoData.nombre) | Precio: \(productoData.precioSinIVA) | Cantidad: \(productoData.cantidad)")

                    if !codigoBuscado.isEmpty {
                        if let existente = productosEmpresa.first(where: { $0.codigoFactura == codigoBuscado }) {
                            print("⚠️ Ya existe en DB por código factura: \(existente.nombre) | XML trae: \(productoData.nombre)")
                            productosConflicto.append(ProductoConflicto(
                                productoEnDB: existente,
                                datosNuevos: productoDataAImport(productoData)
                            ))
                            continue
                        }
                    }

                    if !barrasBuscadas.isEmpty {
                        if let existente = productosEmpresa.first(where: { $0.codigoBarras == barrasBuscadas }) {
                            print("⚠️ Ya existe en DB por código barras: \(existente.nombre) | XML trae: \(productoData.nombre)")
                            productosConflicto.append(ProductoConflicto(
                                productoEnDB: existente,
                                datosNuevos: productoDataAImport(productoData)
                            ))
                            continue
                        }
                    }

                    let codigoBarrasLimpio  = (codigosBarrasCount[productoData.codigoBarras]?.count ?? 0) > 1 ? "" : productoData.codigoBarras
                    let codigoFacturaLimpio = (codigosFacturaCount[productoData.codigo]?.count ?? 0) > 1 ? "" : productoData.codigo

                    productosParaImportar.append(ProductoImport(
                        codigo: codigoFacturaLimpio,
                        codigoBarras: codigoBarrasLimpio,
                        nombre: productoData.nombre,
                        cantidad: productoData.cantidad,
                        precioSinIVA: productoData.precioSinIVA,
                        vieneEnPaquetes: false,
                        cantidadPaquetes: 1,
                        codigoBarrasAutomatico: !codigoBarrasLimpio.isEmpty,
                        codigoInterno: "",
                        tieneDescuento: false,
                        porcentajeDescuento: productoData.porcentajeDescuento
                    ))
                }

            } catch {
                print("Error leyendo el archivo: \(error)")
            }

        case .failure(let error):
            print("Error al abrir el archivo: \(error)")
        }
    }

    private func productoDataAImport(_ p: (codigo: String, codigoBarras: String, nombre: String, cantidad: String, precioSinIVA: String, tieneDescuento: Bool, porcentajeDescuento: Double)) -> ProductoImport {
        ProductoImport(
            codigo: p.codigo,
            codigoBarras: p.codigoBarras,
            nombre: p.nombre,
            cantidad: p.cantidad,
            precioSinIVA: p.precioSinIVA,
            vieneEnPaquetes: false,
            cantidadPaquetes: 1,
            codigoBarrasAutomatico: !p.codigoBarras.isEmpty,
            codigoInterno: "",
            tieneDescuento: p.tieneDescuento,
            porcentajeDescuento: p.porcentajeDescuento
        )
    }

    // MARK: - Guardar

    private func guardarProductosNuevos() {
        print("🟡 Iniciando guardado de \(productosParaImportar.count) productos")

        for productoData in productosParaImportar {
            print("📦 Procesando: \(productoData.nombre) | codigoInterno: '\(productoData.codigoInterno)' | barras: '\(productoData.codigoBarras)'")

            let producto = Producto(
                codigoFactura: productoData.codigo,
                codigoBarras: productoData.codigoBarras,
                nombre: productoData.nombre
            )
            producto.codigoDeBarrasAutomatico = !producto.codigoBarras.isEmpty
            producto.vieneEnPaquetes  = productoData.vieneEnPaquetes
            producto.cantidadPaquetes = productoData.cantidadPaquetes
            producto.codigoInterno    = productoData.codigoInterno
            producto.empresa          = empresaActual
            modelContext.insert(producto)

            print("✅ Insertado: \(producto.nombre) | codigoInterno: '\(producto.codigoInterno)'")
        }

        do {
            try modelContext.save()
            print("💾 Guardado exitoso")
            productosGuardados = productosParaImportar.count
            mostrarExito = true  // ← activa la pantalla de éxito
        } catch {
            print("❌ Error guardando: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    AgregarXML(selectedTab: .constant(1))
        .modelContainer(for: [Empresa.self, Producto.self], inMemory: true)
        .environment(AppState())
    
}
