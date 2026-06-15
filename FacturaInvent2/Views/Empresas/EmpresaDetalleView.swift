//
//  EmpresaDetalleView.swift
//  FacturaInvent2
//
//  Productos de la empresa: lista con búsqueda, alta/edición/borrado y
//  exportación del inventario a Excel (lo genera el backend).
//

import SwiftUI

struct EmpresaDetalleView: View {
    @State var empresa: Empresa

    @State private var productos: [Producto] = []
    @State private var busqueda = ""
    @State private var cargando = false
    @State private var error: String?
    @State private var mostrandoNuevoProducto = false
    @State private var mostrandoEditarEmpresa = false
    @State private var archivoExportado: ArchivoExportado?
    @State private var exportando = false

    var productosFiltrados: [Producto] {
        guard !busqueda.isEmpty else { return productos }
        let texto = busqueda.lowercased()
        return productos.filter {
            $0.nombre.lowercased().contains(texto)
                || ($0.codigoBarras ?? "").lowercased().contains(texto)
                || ($0.codigoFactura ?? "").lowercased().contains(texto)
                || ($0.codigoInterno ?? "").lowercased().contains(texto)
        }
    }

    var body: some View {
        List {
            ForEach(productosFiltrados) { producto in
                NavigationLink(value: producto) {
                    FilaProducto(producto: producto)
                }
            }
            .onDelete { offsets in
                Task { await eliminar(offsets) }
            }
        }
        .navigationTitle(empresa.nombre)
        .searchable(text: $busqueda, prompt: "Nombre, código o código de barras")
        .navigationDestination(for: Producto.self) { producto in
            ProductoDetalleView(producto: producto) {
                await cargar()
            }
        }
        .task { await cargar() }
        .refreshable { await cargar() }
        .overlay {
            if productos.isEmpty && cargando {
                ProgressView("Cargando…")
            } else if productos.isEmpty, let error {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else if productos.isEmpty {
                ContentUnavailableView(
                    "Sin productos", systemImage: "shippingbox",
                    description: Text("Agrega productos o importa una factura XML")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        mostrandoNuevoProducto = true
                    } label: {
                        Label("Agregar producto", systemImage: "plus")
                    }
                    Button {
                        mostrandoEditarEmpresa = true
                    } label: {
                        Label("Editar empresa", systemImage: "pencil")
                    }
                    Button {
                        Task { await exportar() }
                    } label: {
                        Label("Exportar inventario a Excel", systemImage: "tablecells")
                    }
                } label: {
                    if exportando {
                        ProgressView()
                    } else {
                        Label("Opciones", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $mostrandoNuevoProducto) {
            ProductoFormSheet(empresaId: empresa.id) {
                await cargar()
            }
        }
        .sheet(isPresented: $mostrandoEditarEmpresa) {
            EmpresaFormSheet(empresa: empresa) { nombre, nit in
                empresa = try await EmpresasEndpoint.actualizar(id: empresa.id, nombre: nombre, nit: nit)
            }
        }
        .sheet(item: $archivoExportado) { archivo in
            HojaCompartirArchivo(url: archivo.url, titulo: "Inventario en Excel")
        }
    }

    private func cargar() async {
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            productos = try await ProductosEndpoint.listar(empresaId: empresa.id)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func eliminar(_ offsets: IndexSet) async {
        for index in offsets {
            let producto = productosFiltrados[index]
            do {
                try await ProductosEndpoint.eliminar(id: producto.id)
            } catch {
                self.error = error.localizedDescription
                return
            }
        }
        await cargar()
    }

    private func exportar() async {
        exportando = true
        defer { exportando = false }
        do {
            let url = try await ProductosEndpoint.exportarExcel(empresaId: empresa.id, nit: empresa.nit)
            archivoExportado = ArchivoExportado(url: url)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

struct FilaProducto: View {
    let producto: Producto

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(producto.nombre)
                .lineLimit(1)
            HStack {
                if let codigo = producto.codigoFactura, !codigo.isEmpty {
                    Text(codigo)
                }
                Spacer()
                Text(producto.precio.pesos)
                    .monospacedDigit()
                Text("× \(producto.cantidadProductos)")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        EmpresaDetalleView(empresa: Empresa(id: 1, nombre: "Distribuidora", nit: "900123456", createdAt: nil))
    }
}
