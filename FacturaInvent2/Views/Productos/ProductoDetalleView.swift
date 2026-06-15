//
//  ProductoDetalleView.swift
//  FacturaInvent2
//
//  Edición de un producto existente (mismos campos que v1).
//

import SwiftUI

struct ProductoDetalleView: View {
    let producto: Producto
    let onCambio: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var codigoFactura: String = ""
    @State private var codigoBarras: String = ""
    @State private var codigoInterno: String = ""
    @State private var nombre: String = ""
    @State private var cantidad: Int = 0
    @State private var precio: Int = 0
    @State private var precioDividido: Int = 1
    @State private var vieneEnPaquetes = false
    @State private var cantidadPaquetes: Int = 1
    @State private var tieneDescuento = false
    @State private var codigoBarrasAutomatico = false

    @State private var error: String?
    @State private var guardando = false

    var body: some View {
        Form {
            Section("Producto") {
                TextField("Nombre", text: $nombre)
                CampoNumero(titulo: "Cantidad", valor: $cantidad)
                CampoPesos(titulo: "Precio", valor: $precio)
                CampoNumero(titulo: "Precio dividido entre", valor: $precioDividido)
            }
            Section("Códigos") {
                TextField("Código de factura", text: $codigoFactura)
                TextField("Código de barras", text: $codigoBarras)
                TextField("Código interno", text: $codigoInterno)
                Toggle("Código de barras automático", isOn: $codigoBarrasAutomatico)
            }
            Section("Paquetes y descuento") {
                Toggle("Viene en paquetes", isOn: $vieneEnPaquetes)
                if vieneEnPaquetes {
                    CampoNumero(titulo: "Cantidad de paquetes", valor: $cantidadPaquetes)
                }
                Toggle("Tiene descuento", isOn: $tieneDescuento)
            }
            if let error {
                Section {
                    Text(error).foregroundStyle(.red).font(.callout)
                }
            }
            Section {
                Button {
                    Task { await guardar() }
                } label: {
                    if guardando {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Guardar cambios").bold().frame(maxWidth: .infinity)
                    }
                }
                .disabled(nombre.isEmpty || guardando)
            }
        }
        .navigationTitle(nombre.isEmpty ? "Producto" : nombre)
        .onAppear { cargarValores() }
    }

    private func cargarValores() {
        codigoFactura = producto.codigoFactura ?? ""
        codigoBarras = producto.codigoBarras ?? ""
        codigoInterno = producto.codigoInterno ?? ""
        nombre = producto.nombre
        cantidad = producto.cantidadProductos
        precio = producto.precio
        precioDividido = producto.precioDividido
        vieneEnPaquetes = producto.vieneEnPaquetes
        cantidadPaquetes = producto.cantidadPaquetes
        tieneDescuento = producto.tieneDescuento
        codigoBarrasAutomatico = producto.codigoBarrasAutomatico
    }

    private func guardar() async {
        guardando = true
        defer { guardando = false }
        let payload = ProductoNuevo(
            codigoFactura: codigoFactura.isEmpty ? nil : codigoFactura,
            codigoBarras: codigoBarras.isEmpty ? nil : codigoBarras,
            nombre: nombre,
            cantidadProductos: cantidad,
            precio: precio,
            precioDividido: precioDividido,
            vieneEnPaquetes: vieneEnPaquetes,
            cantidadPaquetes: cantidadPaquetes,
            codigoInterno: codigoInterno.isEmpty ? nil : codigoInterno,
            tieneDescuento: tieneDescuento,
            codigoBarrasAutomatico: codigoBarrasAutomatico
        )
        do {
            _ = try await ProductosEndpoint.actualizar(id: producto.id, producto: payload)
            await onCambio()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// MARK: - Alta de producto

struct ProductoFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    let empresaId: Int
    let onCreado: () async -> Void

    @State private var nombre = ""
    @State private var codigoFactura = ""
    @State private var codigoBarras = ""
    @State private var cantidad = 0
    @State private var precio = 0
    @State private var error: String?
    @State private var guardando = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Código de factura", text: $codigoFactura)
                TextField("Código de barras", text: $codigoBarras)
                CampoNumero(titulo: "Cantidad", valor: $cantidad)
                CampoPesos(titulo: "Precio", valor: $precio)
                if let error {
                    Text(error).foregroundStyle(.red).font(.callout)
                }
            }
            .navigationTitle("Nuevo producto")
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
                    .disabled(nombre.isEmpty || guardando)
                }
            }
        }
    }

    private func guardar() async {
        guardando = true
        defer { guardando = false }
        var payload = ProductoNuevo(nombre: nombre)
        payload.codigoFactura = codigoFactura.isEmpty ? nil : codigoFactura
        payload.codigoBarras = codigoBarras.isEmpty ? nil : codigoBarras
        payload.cantidadProductos = cantidad
        payload.precio = precio
        do {
            _ = try await ProductosEndpoint.crear(empresaId: empresaId, producto: payload)
            await onCreado()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

/// Campo numérico entero simple (cantidades, divisores).
struct CampoNumero: View {
    let titulo: String
    @Binding var valor: Int

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField("0", value: $valor, format: .number)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
                #if !targetEnvironment(macCatalyst)
                .keyboardType(.numberPad)
                #endif
        }
    }
}
