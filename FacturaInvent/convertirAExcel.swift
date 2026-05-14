//  convertirAExcel.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.

import SwiftData
import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if targetEnvironment(macCatalyst)
struct DocumentExporter: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        init(isPresented: Binding<Bool>) { _isPresented = isPresented }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { isPresented = false }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) { isPresented = false }
    }
}
#endif

struct ExportarExcelView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var urlParaCompartir: URL? = nil
    @State private var productosParaImportar: [ProductoImport] = []
    @State private var empresaActual: Empresa? = nil
    @State private var mostrarFilePicker = false
    @State private var mostrarGuardarEn = false
    @State private var errorMensaje: String? = nil
    @State private var mostrarError = false
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            Group {
                if let url = urlParaCompartir {
                    vistaExito(url: url)
                } else if productosParaImportar.isEmpty {
                    vistaVacia
                } else {
                    vistaListaProductos
                }
            }
        }
        .alert("Error", isPresented: $mostrarError, presenting: errorMensaje) { _ in
            Button("OK", role: .cancel) {}
        } message: { mensaje in
            Text(mensaje)
        }
    }

    // MARK: - Subvistas

    private var vistaVacia: some View {
        VStack {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .padding()
            Text("First you need to add a XML file")
            Button {
                mostrarFilePicker = true
            } label: {
                Label("Add XML", systemImage: "doc.text")
            }
            .buttonStyle(.glassProminent)
        }
        .navigationTitle("New Xlsx File")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { selectedTab = 0 }
            }
        }
        .fileImporter(
            isPresented: $mostrarFilePicker,
            allowedContentTypes: [UTType.xml],
            onCompletion: procesarArchivoXML
        )
    }

    private var vistaListaProductos: some View {
        List {
            ForEach($productosParaImportar) { $producto in
                NavigationLink(destination: PreviewProducto(
                    producto: $producto,
                    modoExcelPreview: true,
                    onEliminar: {
                        productosParaImportar.removeAll { $0.id == producto.id }
                    }
                )) {
                    VStack(alignment: .leading) {
                        Text(producto.nombre)
                        Text(verbatim: producto.codigo)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Review Products")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { reiniciarProceso() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm") {
                    confirmarYExportar()
                }
            }
        }
    }

    private func vistaExito(url: URL) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)

            Text("Excel generated")
                .font(.title2.bold())

            Text("The file is ready to export.")
                .foregroundStyle(.secondary)

            #if targetEnvironment(macCatalyst)
            Button {
                mostrarGuardarEn = true
            } label: {
                Label("Save to...", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.glassProminent)
            .sheet(isPresented: $mostrarGuardarEn) {
                DocumentExporter(url: url, isPresented: $mostrarGuardarEn)
            }
            #else
            ShareLink(
                item: url,
                preview: SharePreview("productos.xlsx", icon: Image(systemName: "doc.fill"))
            ) {
                Label("Share Excel", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.glassProminent)
            #endif
        }
        .navigationTitle("Success")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { reiniciarProceso() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Start Over") { reiniciarProceso() }
            }
        }
    }

    // MARK: - Acciones

    private func confirmarYExportar() {
        for productoData in productosParaImportar {
            let cantidadInt   = Int(Double(productoData.cantidad) ?? 0)
            let totalPaquetes = cantidadInt * productoData.cantidadPaquetes
            let codigoBuscado = productoData.codigo

            let descriptor = FetchDescriptor<Producto>(
                predicate: #Predicate { p in p.codigoFactura == codigoBuscado }
            )
            if let producto = try? modelContext.fetch(descriptor).first {
                producto.cantidadProductos = totalPaquetes
                let precioParsed = Int(Double(productoData.precioSinIVA.replacingOccurrences(of: ",", with: ".")) ?? 0)
                let cantPaquetes = productoData.cantidadPaquetes > 0 ? productoData.cantidadPaquetes : 1
                producto.precio = precioParsed / cantPaquetes
            }
            let precioDividido = (Double(productoData.precioSinIVA.replacingOccurrences(of: ",", with: ".")) ?? 0) / Double(productoData.cantidadPaquetes > 0 ? productoData.cantidadPaquetes : 1)
            print("Datos definitivos Excel: \(productoData.codigoInterno) | Precio unitario: \(String(format: "%.2f", precioDividido)) | cantidadPaquetes: \(productoData.cantidadPaquetes) | Cantidad: \(totalPaquetes) Tiene Descuento: \(productoData.tieneDescuento)")
        }

        do {
            try modelContext.save()
        } catch {
            print("❌ Error guardando contexto: \(error)")
            errorMensaje = "No se pudo guardar los cambios: \(error.localizedDescription)"
            mostrarError = true
            return
        }

        guard let url = exportarExcel(productos: productosParaImportar) else {
            errorMensaje = "No se pudo generar el archivo Excel. Inténtalo de nuevo."
            mostrarError = true
            return
        }

        urlParaCompartir = url
    }

    private func reiniciarProceso() {
        urlParaCompartir = nil
        productosParaImportar = []
        empresaActual = nil
        mostrarFilePicker = false
    }

    private func procesarArchivoXML(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                print("Sin permiso para acceder al archivo")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let contenido = try String(contentsOf: url, encoding: .utf8)
                guard
                    let inicio = contenido.range(of: "<![CDATA["),
                    let fin    = contenido.range(of: "]]>")
                else {
                    print("Error: no se encontró el bloque CDATA en el XML")
                    errorMensaje = "El archivo XML no tiene el formato esperado."
                    mostrarError = true
                    return
                }

                let factura = String(contenido[inicio.upperBound..<fin.lowerBound])
                guard let data = factura.data(using: .utf8) else { return }

                let xmlparser = XMLParser(data: data)
                let delegado  = XMLFacturaParser()
                xmlparser.delegate = delegado
                xmlparser.shouldProcessNamespaces = true
                xmlparser.parse()

                print("Productos encontrados: \(delegado.productos.count)")
                print("Empresa: \(delegado.nombreEmpresa) | Nit: \(delegado.nit)")
                
//se modifica la funcion para que envez de buscar el producto en toda la base de datos solo lo busque en la empresa correspondiente
                let nitBuscado = delegado.nit
                let empresaEcontrada: Empresa? = try? modelContext.fetch(FetchDescriptor<Empresa>(predicate: #Predicate{ $0.nit == nitBuscado})).first
                
                empresaActual = empresaEcontrada

                for productoData in delegado.productos {
                    let productoEncontrado = buscarProducto(productoData: productoData, empresa: empresaEcontrada)
                    productosParaImportar.append(ProductoImport(
                        codigo:                 productoData.codigo,
                        codigoBarras:           productoEncontrado?.codigoBarras ?? productoData.codigoBarras,
                        nombre:                 productoData.nombre,
                        cantidad:               productoData.cantidad,
                        precioSinIVA:           productoData.precioSinIVA,
                        vieneEnPaquetes:        productoEncontrado?.vieneEnPaquetes ?? false,
                        cantidadPaquetes:       productoEncontrado?.cantidadPaquetes ?? 1,
                        codigoBarrasAutomatico: productoEncontrado?.codigoDeBarrasAutomatico ?? false,
                        codigoInterno:          productoEncontrado?.codigoInterno ?? "",
                        tieneDescuento:         productoData.tieneDescuento,
                        porcentajeDescuento: productoData.porcentajeDescuento,
                        empresa: empresaEcontrada
                    ))
                    print("codigo: \(productoData.codigo) | Barras: \(productoEncontrado?.codigoBarras ?? "Sin codigo de barras")| Codigo Interno: \(productoEncontrado?.codigoInterno ?? "Sin codigo Interno") | Nombre: \(productoData.nombre) | Precio: \(productoData.precioSinIVA) | Cantidad: \(productoData.cantidad)")
                }

            } catch {
                print("Error leyendo el archivo: \(error)")
                errorMensaje = "No se pudo leer el archivo: \(error.localizedDescription)"
                mostrarError = true
            }

        case .failure(let error):
            print("Error al seleccionar el archivo: \(error)")
            errorMensaje = "No se pudo abrir el archivo."
            mostrarError = true
        }
    }

    // MARK: - Búsqueda en cascada

    /// Busca un producto primero por código de factura, luego por código de barras, luego por nombre.
    /// se modifica esta funcion para que busque solo los productos de la empresa en la que estamos , se soluciona error que hacia que buscara productos en otras empresas y pusiera codigos erroneos
    private func buscarProducto(
        productoData: (codigo: String, codigoBarras: String, nombre: String, cantidad: String, precioSinIVA: String, tieneDescuento: Bool, porcentajeDescuento: Double),
        empresa: Empresa?
    ) -> Producto? {
        let productosEmpresa = empresa?.productos ?? []
        
        if !productoData.codigo.isEmpty,
           let p = productosEmpresa.first(where: { $0.codigoFactura == productoData.codigo }) { return p }
        
        if !productoData.codigoBarras.isEmpty,
           let p = productosEmpresa.first(where: { $0.codigoBarras == productoData.codigoBarras }) { return p }
        
        if !productoData.nombre.isEmpty,
           let p = productosEmpresa.first(where: { $0.nombre == productoData.nombre }) { return p }
        
        return nil
    }
}

// MARK: - Preview

#Preview {
    ExportarExcelView(selectedTab: .constant(2))
        .modelContainer(for: [Empresa.self, Producto.self], inMemory: true)
}
