//
//  BuscarTab.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 26/04/26.
//
import SwiftUI
import Foundation
import SwiftData

struct Buscador: View {
    @Query var empresas: [Empresa]
    @Query var productos: [Producto]
    @State private var busqueda: String = ""
    @Binding var selectedTab: Int
    var empresasFiltradas: [Empresa] {
        if busqueda.isEmpty { return empresas }
        return empresas.filter {
            $0.nombre.localizedCaseInsensitiveContains(busqueda) ||
            $0.nit.localizedCaseInsensitiveContains(busqueda)
        }
    }

    var productosFiltrados: [Producto] {
        if busqueda.isEmpty { return productos }
        return productos.filter {
            $0.nombre.localizedCaseInsensitiveContains(busqueda) ||
            $0.codigoFactura.localizedCaseInsensitiveContains(busqueda) ||
            $0.codigoBarras.localizedCaseInsensitiveContains(busqueda) ||
            $0.codigoInterno.localizedCaseInsensitiveContains(busqueda)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Businesses") {
                    ForEach(empresasFiltradas) { empresa in
                        NavigationLink(destination: EmpresaDetalle(empresa: empresa, selectedTab: $selectedTab)) {
                            VStack(alignment: .leading) {
                                Text(empresa.nombre)
                                Text("NIT: \(empresa.nit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Products") {
                    ForEach(productosFiltrados) { producto in
                        NavigationLink(destination: DetalleProducto(producto: producto)) {
                            VStack(alignment: .leading) {
                                Text(producto.nombre)
                                Text(producto.codigoInterno)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $busqueda, prompt: "Search businesses or products")
            .navigationTitle("Search")
        }
    }
}
