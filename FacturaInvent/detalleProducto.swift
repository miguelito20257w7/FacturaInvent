//
//  detalleProducto.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/11/26.
//

import SwiftData
import SwiftUI

struct DetalleProducto: View {
    @Bindable  var producto: Producto
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var codigoBarrasTemp: String = ""
    @State private var showTextField: Bool = false
    @State private var codigoInternoTemp: String = ""
    @State private var nombreTemp: String = ""
    @State private var showTextFieldPaquete: Bool = false
    @State private var cantidadPaquetesTemp: Int = 0
    @State private var showdeleteButton: Bool = false
    @State private var showTextFieldName: Bool = false
    var body: some View {
        VStack{
            List{
                Section ("Product info and barcode"){// seccion de informcion del producto
                    HStack{
                        if showTextFieldName {
                            TextEditor(text: $nombreTemp)
                                .onAppear {
                                    nombreTemp = producto.nombre
                                }
                                .font(.title3)
                                .onDisappear{
                                    producto.nombre = nombreTemp
                                    showTextFieldName = false
                                }
                            Spacer()
                            Button{
                                producto.nombre = nombreTemp
                                showTextFieldName = false
                            }label: {
                                Image(systemName: "checkmark.circle.fill")
                            }.buttonStyle(.glassProminent)
                        } else {
                            Text(producto.nombre)
                                .font(.title3)
                            Spacer()
                            Button("Change") {
                                showTextFieldName = true
                            }
                        }
                    }
                    Text("Found in bill: \(producto.codigoDeBarrasAutomatico ? "Yes" : "No")")
                    if !producto.codigoBarras.isEmpty && !showTextField {// si el campo de codigo de barras esta vacio y no esta el campo de textfield activo , mostrar los botones de cambiar
                                       HStack {
                                           Text("Bar code: \(producto.codigoBarras)")
                                           Button("Change") {
                                               showTextField = true
                                           }
                                       }
                                   }
                                   if !producto.codigoInterno.isEmpty && !showTextField {// lo mismo pero ahora aplicado al codigo de barras
                                       HStack {
                                           Text("Intern Code: \(producto.codigoInterno)")
                                           Button("Change") {
                                               showTextField = true
                                           }
                                       }
                                   }else {
                                       HStack {// ahora , si no hay nada mostrar el textfield
                                           TextField("Bar code", text: $codigoBarrasTemp)
                                               .keyboardType(.numberPad)
                                               .onAppear { codigoBarrasTemp = producto.codigoBarras }
                                           if !codigoBarrasTemp.isEmpty {
                                               Button {
                                                   producto.codigoBarras = codigoBarrasTemp
                                                   try? modelContext.save()
                                                   showTextField = false
                                               } label: {
                                                   Image(systemName: "checkmark.circle.fill")
                                               }.buttonStyle(.glassProminent)
                                           }
                                           TextField("Intern Code", text: $codigoInternoTemp)
                                               .keyboardType(.numberPad)
                                               .onAppear { codigoInternoTemp = producto.codigoInterno }
                                           if !codigoInternoTemp.isEmpty {
                                               Button {
                                                   producto.codigoInterno = codigoInternoTemp
                                                   try? modelContext.save()
                                                   showTextField = false
                                               } label: {
                                                   Image(systemName: "checkmark.circle.fill")
                                               }.buttonStyle(.glassProminent)
                                           }
                                       }
                    }
                    
                }
                Section ("Advanced") {// seccion para separar si viene en paquetes
                    Toggle("Package to unit", isOn: $producto.vieneEnPaquetes )
                        .onChange(of: producto.vieneEnPaquetes){// el onChange siempre debe ir despues del toggle
                            _, nuevoValor in if !nuevoValor {
                                producto.cantidadPaquetes = 1
                                try? modelContext.save()
                            }
                        }
                    
                    if producto.vieneEnPaquetes {
                        HStack{
                          if !showTextFieldPaquete {
                            Text("Units per package: \(producto.cantidadPaquetes)")
                              Spacer()
                              Button("Change"){
                                  showTextFieldPaquete = true
                              }
                          }else {
                              Text("Units per package: ")
                              TextField("Quantity", value: $cantidadPaquetesTemp, format: .number)
                              .keyboardType(.numberPad)
                                  .onAppear { cantidadPaquetesTemp = producto.cantidadPaquetes }
                                  .onDisappear{
                                      producto.cantidadPaquetes = cantidadPaquetesTemp
                                      try? modelContext.save()
                                      showTextFieldPaquete = false
                                      
                                  }
                              Spacer()
                              Button{
                                  producto.cantidadPaquetes = cantidadPaquetesTemp
                                  try? modelContext.save()
                                  showTextFieldPaquete = false
                              } label: {
                                  Image(systemName: "checkmark.circle.fill")
                              }.buttonStyle(.glassProminent)
                          }
                           
                        }
                    }
                    
                }
                Section("Delete"){
                    HStack{
                        Text("This action can't be undone")
                        Spacer()
                        Button{
                            showdeleteButton = true
                        }label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .padding(5)
                                .frame(width: 30, height: 30)
                        }.buttonStyle(.glassProminent)
                            .alert("Delete?", isPresented: $showdeleteButton) {
                                Button("Delete", role:.destructive ){
                                    modelContext.delete(producto)
                                    try? modelContext.save()
                                    dismiss()
                                }
                                Button("Cancel", role:.cancel){}
                            } message: {
                                Text("This action can't be undone")
                            }
                    }
                }
            }
            
        }.navigationTitle("Modify product")
        
    }
}

#Preview {
    DetalleProducto(producto: Producto(codigoFactura: "23626", codigoBarras: "7702090072518", nombre: "SPEED MAX"))
        .modelContainer(for: [Empresa.self, Producto.self], inMemory: true)
}
