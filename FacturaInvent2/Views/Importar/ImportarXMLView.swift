//
//  ImportarXMLView.swift
//  FacturaInvent2
//
//  Importa una factura electrónica DIAN (XML UBL 2.1, con CDATA anidado):
//  1. El XMLFacturaParser de v1 extrae NIT, nombre de empresa y productos.
//  2. Se busca la empresa por NIT (o se crea).
//  3. El backend deduplica y suma cantidades.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportarXMLView: View {
    var xmlURLInicial: URL? = nil

    @State private var mostrandoFilePicker = false
    @State private var nitParseado = ""
    @State private var nombreEmpresaParseado = ""
    @State private var productosParseados: [ProductoImportado] = []
    @State private var error: String?
    @State private var importando = false
    @State private var resumen: ResumenImportacion?
    @State private var urlProcesada: URL?

    var body: some View {
        Group {
            if productosParseados.isEmpty {
                pantallaInicial
            } else {
                vistaPrevia
            }
        }
        .navigationTitle("Agregar factura")
        .fileImporter(
            isPresented: $mostrandoFilePicker,
            allowedContentTypes: [.xml],
            allowsMultipleSelection: false
        ) { resultado in
            switch resultado {
            case .success(let urls):
                if let url = urls.first { procesarXML(url: url, esSeguro: false) }
            case .failure(let fallo):
                error = fallo.localizedDescription
            }
        }
        .onAppear {
            if let url = xmlURLInicial, url != urlProcesada {
                procesarXML(url: url, esSeguro: true)
            }
        }
        .onChange(of: xmlURLInicial) { _, nueva in
            if let url = nueva, url != urlProcesada {
                procesarXML(url: url, esSeguro: true)
            }
        }
        .alert("Importación completada", isPresented: .init(
            get: { resumen != nil },
            set: { if !$0 { resumen = nil } }
        )) {
            Button("OK") { limpiar() }
        } message: {
            if let resumen {
                Text("Productos nuevos: \(resumen.creados)\nActualizados: \(resumen.actualizados)")
            }
        }
    }

    // MARK: - Pantallas

    private var pantallaInicial: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text("Importa una factura electrónica DIAN (XML) para crear o actualizar los productos de la empresa.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button {
                mostrandoFilePicker = true
            } label: {
                Label("Elegir archivo XML", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            if let error {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    private var vistaPrevia: some View {
        List {
            Section("Empresa") {
                FilaDato("Nombre", nombreEmpresaParseado.isEmpty ? "—" : nombreEmpresaParseado)
                FilaDato("NIT", nitParseado.isEmpty ? "—" : nitParseado)
            }
            Section("Productos (\(productosParseados.count))") {
                ForEach(productosParseados) { producto in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(producto.nombre).lineLimit(1)
                        HStack {
                            if let codigo = producto.codigoFactura, !codigo.isEmpty {
                                Text(codigo)
                            }
                            Spacer()
                            Text(producto.precio.pesos).monospacedDigit()
                            Text("× \(producto.cantidad)").foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            if let error {
                Section {
                    Text(error).foregroundStyle(.red).font(.callout)
                }
            }
            Section {
                Button {
                    Task { await importar() }
                } label: {
                    if importando {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Importar a la base de datos")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(importando || nitParseado.isEmpty)
                Button("Descartar", role: .destructive) {
                    limpiar()
                }
            }
        }
    }

    // MARK: - Lógica

    private func procesarXML(url: URL, esSeguro: Bool) {
        error = nil
        urlProcesada = url

        let necesitaPermiso = !esSeguro && url.startAccessingSecurityScopedResource()
        defer {
            if necesitaPermiso { url.stopAccessingSecurityScopedResource() }
        }

        guard let data = try? Data(contentsOf: url) else {
            error = "No se pudo leer el archivo"
            return
        }

        let parser = XMLFacturaParser()
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = parser
        xmlParser.parse()

        guard !parser.productos.isEmpty else {
            error = "El XML no contiene productos (¿es una factura DIAN UBL 2.1?)"
            return
        }

        nitParseado = parser.nit
        nombreEmpresaParseado = parser.nombreEmpresa
        productosParseados = parser.productos.map { item in
            ProductoImportado(
                codigoFactura: item.codigo.isEmpty ? nil : item.codigo,
                codigoBarras: item.codigoBarras.isEmpty ? nil : item.codigoBarras,
                nombre: item.nombre,
                cantidad: Int(Double(item.cantidad) ?? 0),
                precio: Int((Double(item.precioSinIVA) ?? 0).rounded()),
                tieneDescuento: item.tieneDescuento
            )
        }
    }

    private func importar() async {
        importando = true
        error = nil
        defer { importando = false }
        do {
            let empresa: Empresa
            if let existente = try await EmpresasEndpoint.buscarPorNIT(nitParseado) {
                empresa = existente
            } else {
                empresa = try await EmpresasEndpoint.crear(
                    nombre: nombreEmpresaParseado.isEmpty ? "Empresa \(nitParseado)" : nombreEmpresaParseado,
                    nit: nitParseado
                )
            }
            resumen = try await ProductosEndpoint.importar(empresaId: empresa.id, productos: productosParseados)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func limpiar() {
        productosParseados = []
        nitParseado = ""
        nombreEmpresaParseado = ""
        error = nil
    }
}

#Preview {
    NavigationStack { ImportarXMLView() }
}
