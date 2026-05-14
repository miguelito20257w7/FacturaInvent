//
//  previewProducto.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/11/26.
//

import SwiftUI
import SwiftData

struct PreviewProducto: View {
    @Binding var producto: ProductoImport
    @State private var showTextField: Bool = false
    @State private var showTextFieldName: Bool = false
    @State private var showTextFieldPaquete: Bool = false
    @State private var cantidadPaquetesTemp: Int = 0
    @State private var codigoBarrasTemp: String = ""
    @State private var codigoInternoTemp: String = ""
    @State private var nombreTemp: String = ""
    @State private var cantidadTemp: Int = 0
    @Environment(\.dismiss) private var dismiss
    var modoExcelPreview: Bool = false
    var onEliminar: () -> Void
    
    var body: some View {
        List {
            Section("Product info and barcode") {
                HStack{
                    if showTextFieldName {
                        TextEditor(text: $nombreTemp)
                            .onAppear {
                                nombreTemp = producto.nombre
                            }
                            .disabled(modoExcelPreview)
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
                Text("Found in bill: \(producto.codigoBarrasAutomatico ? "Yes" : "No")")
                if !producto.codigoBarras.isEmpty && !showTextField && !producto.codigoInterno.isEmpty {
                    HStack {
                        Text("Bar code: \(producto.codigoBarras)")
                        Spacer()
                        Button("Change") {
                            showTextField = true
                        }.disabled(modoExcelPreview)
                    }
                }
                if !producto.codigoInterno.isEmpty && !showTextField {
                    HStack {
                        Text("Intern Code: \(producto.codigoInterno)")
                        Button("Change") {
                            showTextField = true
                        }.disabled(modoExcelPreview)
                    }
                }else {
                    if !modoExcelPreview {
                        HStack {
                            TextField("Bar code", text: $codigoBarrasTemp)
                                .keyboardType(.numberPad)
                                .onAppear { codigoBarrasTemp = producto.codigoBarras }
                                .onDisappear {
                                    producto.codigoBarras = codigoBarrasTemp
                                }
                            if !codigoBarrasTemp.isEmpty {
                                Button {
                                    producto.codigoBarras = codigoBarrasTemp
                                    showTextField = false
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }.buttonStyle(.glassProminent)
                            }
                            TextField("Intern Code", text: $codigoInternoTemp)
                                .keyboardType(.numberPad)
                                .onAppear { codigoInternoTemp = producto.codigoInterno }
                                .onDisappear {
                                    producto.codigoInterno = codigoInternoTemp
                                }
                            if !codigoInternoTemp.isEmpty {
                                Button {
                                    producto.codigoInterno = codigoInternoTemp
                                    showTextField = false
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }.buttonStyle(.glassProminent)
                            }
                        }
                    }

                }
            }
            if modoExcelPreview {
                Section("Upload items:") {
                    HStack {
                        TextField("Quantity", value: $cantidadTemp, format: .number) // hay que poner que es un numero
                            .keyboardType(.numberPad)
                            .onAppear {
                                cantidadTemp = Int(Double(producto.cantidad) ?? 0)
                            }
                        if cantidadTemp > 0 {
                            Button {
                                producto.cantidad = String(cantidadTemp)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                            }.buttonStyle(.glassProminent)
                        }
                    }
                }
            }
            Section("Price"){
                Text("Price: \(producto.precioSinIVA)")
                if modoExcelPreview {
                    Toggle("Has discount", isOn: $producto.tieneDescuento)
                    if producto.tieneDescuento {
                        HStack {
                            Text("Discount")
                            Spacer()
                            TextField("0", value: $producto.porcentajeDescuento, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                        }
                        if let precioBase = Double(producto.precioSinIVA.replacingOccurrences(of: ",", with: ".")),
                           producto.porcentajeDescuento > 0 {
                            let precioConDescuento = precioBase * (1 - producto.porcentajeDescuento / 100)
                            Text("Price with discount: \(String(format: "%.2f", precioConDescuento))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            }
            Section("Advanced") {
                Toggle("Package to unit", isOn: $producto.vieneEnPaquetes)
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
                                  showTextFieldPaquete = false
                                  
                              }
                          Spacer()
                          Button{
                              producto.cantidadPaquetes = cantidadPaquetesTemp
                              showTextFieldPaquete = false
                          } label: {
                              Image(systemName: "checkmark.circle.fill")
                          }.buttonStyle(.glassProminent)
                      }
                       
                    }
                }
            }
            Section("Remove from import") {
                HStack {
                    Text("This action can't be undone")
                    Spacer()
                    Button {
                        // aquí no podemos borrar de SwiftData porque aún no está guardado
                        // simplemente lo quitamos del array temporal
                        dismiss()
                        onEliminar()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .padding(5)
                            .frame(width: 30, height: 30)
                    }.buttonStyle(.glassProminent)
                }
            }
        }
        .navigationTitle("Preview product")
    }
}

#Preview {
    PreviewProducto(
        producto: .constant(ProductoImport(
            codigo: "1001439",
            codigoBarras: "7702085012062",
            nombre: "FIDEO DORIA CLASICA X 250G",
            cantidad: "6",
            precioSinIVA: "1863.00",
            vieneEnPaquetes: true,
            cantidadPaquetes: 1,
            codigoBarrasAutomatico: true,
            codigoInterno: "",
            tieneDescuento: false,
            porcentajeDescuento: 0.00
        )),
        modoExcelPreview: false,
        onEliminar: {}
    )
}
