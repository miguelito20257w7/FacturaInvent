//
//  ImportarBaseDeDatos.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 21/04/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportarBaseDeDatos: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var productosParaImportar: [ProductoImport] = []
    @State private var empresaActual: Empresa? = nil
    let storeType = UTType(filenameExtension: "store") ?? .data
    @State private var mostrarFilePicker = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Import .store")
                Button {
                    mostrarFilePicker = true
                } label: {
                    Label("Import .store", systemImage: "doc.text")
                }.buttonStyle(.glassProminent)
            }
            .navigationTitle("Import Database")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $mostrarFilePicker,
                allowedContentTypes: [storeType],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        //le pedimos permiso a apple para leer los archivos
                        //Esto es nesesario porque el archivo esta fuera del sandbox
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Sin permiso para acceder al archivo")
                            return
                        }
                        //cuando terminemos de usar el archivo , liberaremos el permiso
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                        do {
                           // Acciones a realizar con el archivo
                            try modelContext.delete(model: Producto.self)
                            try modelContext.delete(model: Empresa.self)
                            try modelContext.save()
                            // lo primero que vamos a hacer es borrar la base de datos vieja
                            
                                //vamos a hacer la logica para importar la base de datos
                            let config = ModelConfiguration(url: url)
                               let container = try ModelContainer(
                                   for: Empresa.self, Producto.self,
                                   configurations: config
                               )
                            let context = ModelContext(container)
                            
                            let empresas = try context.fetch(FetchDescriptor<Empresa>())
                            let productos = try context.fetch(FetchDescriptor<Producto>())
                            
                            // luego de tener los datos , vamos a escribirlos en sus campos de mi base de datos
                            
                            // Importar empresas y guardar referencia para linkear productos
                            var mapaEmpresas: [PersistentIdentifier: Empresa] = [:]

                            for empresa in empresas {
                                let nueva = Empresa(nombre: empresa.nombre, nit: empresa.nit)
                                modelContext.insert(nueva)
                                mapaEmpresas[empresa.persistentModelID] = nueva
                            }

                            // Importar productos y re-linkearlos a su empresa
                            for producto in productos {
                                let nuevo = Producto(
                                    codigoFactura: producto.codigoFactura,
                                    codigoBarras: producto.codigoBarras,
                                    nombre: producto.nombre
                                )
                                nuevo.codigoDeBarrasAutomatico = producto.codigoDeBarrasAutomatico
                                nuevo.cantidadProductos = producto.cantidadProductos
                                nuevo.precio = producto.precio
                                nuevo.precioDividido = producto.precioDividido
                                nuevo.vieneEnPaquetes = producto.vieneEnPaquetes
                                nuevo.cantidadPaquetes = producto.cantidadPaquetes
                                nuevo.codigoInterno = producto.codigoInterno
                                nuevo.tieneDescuento = producto.tieneDescuento
                                
                                // Re-linkear al empresa nueva usando el mapa
                                if let empresaOriginal = producto.empresa {
                                    nuevo.empresa = mapaEmpresas[empresaOriginal.persistentModelID]
                                }
                                
                                modelContext.insert(nuevo)
                            }

                            try modelContext.save()
                            dismiss()
                            
                        } catch {
                            print("Error leyendo el archivo \(error)")
                        }
                    case .failure:
                        print("Error al leer el archivo")
                    }
                }
            )
        }
    }
}

#Preview {
    ImportarBaseDeDatos()
}
