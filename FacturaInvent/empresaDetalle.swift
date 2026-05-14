//
//  empresaDetalle.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//

import SwiftData
import SwiftUI

struct EmpresaDetalle: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var showDeleteBusiness: Bool = false
    @State private var showChangeName: Bool = false
    @State private var newName: String = ""
    @Binding var selectedTab: Int

    var empresa: Empresa
    @Query var productos: [Producto]

    init(empresa: Empresa, selectedTab: Binding<Int>) {  // init manual requerido para el @Query filtrado
        self.empresa = empresa
        _selectedTab = selectedTab
        let empresaID = empresa.persistentModelID
        _productos = Query(filter: #Predicate<Producto> { producto in
            producto.empresa?.persistentModelID == empresaID
        })
    }
    
    
    var body: some View {
        VStack{
            List{
                ForEach(productos) { producto in
                    NavigationLink(destination: DetalleProducto(producto: producto)) {
                        ZStack{
                            VStack(alignment: .leading){// si quieres que le layout sea lo mas preciso posible , lo mejor es que lo declares explicitamente
                                Text(producto.nombre)
                                Text("Intern Code : \(producto.codigoInterno)")
                                Text("Barcode: \(producto.codigoBarras)")
                            }
                            }
                    }
                }
                
                if !productos.isEmpty {
                    Section("Delete Business / Change Name") {
                        HStack{
                            Text("This action can't be undone")
                            Spacer()
                            Button{
                                showDeleteBusiness = true
                            }label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .padding(5)
                                    .frame(width: 30, height: 30)
                            }.buttonStyle(.glassProminent)
                                .alert("Delete?", isPresented: $showDeleteBusiness) {
                                    Button("Delete", role:.destructive ){
                                        modelContext.delete(empresa)
                                        try? modelContext.save()
                                        dismiss()
                                    }
                                    Button("Cancel", role:.cancel){}
                                } message: {
                                    Text("This action can't be undone")
                                }
                            Button{
                                showChangeName = true
                            }label: {
                                Text("Change Name")
                                    .font(.caption)
                                    .padding(5)
                                    .frame(height: 30)
                            }.buttonStyle(.glassProminent)
                        }.alert("Change Name", isPresented: $showChangeName) { // se agrega boton de cambiar nombre de empresa , adcional ya cambia el nombre
                            TextField("New Name", text: $newName)
                            Button("Change") {
                                empresa.nombre = newName
                                try? modelContext.save()
                            }
                            Button("Cancel", role:.cancel){
                                showChangeName = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: Bindable(appState).mostrarAgregarXML) {
                AgregarXML(selectedTab: $selectedTab)
                    .environment(appState)
                    .interactiveDismissDisabled(true)
            }
            .navigationTitle(empresa.nombre)
            .overlay {
                if empresa.productos?.isEmpty ?? true{
                    
                    VStack (spacing: 20){
                        ContentUnavailableView(
                            "No products",
                            systemImage: "shippingbox",
                            description: Text("Import an XML to add products")
                        )
                        HStack{
                            Button{
                                appState.mostrarAgregarXML = true
                            }label: {
                                Text("Import XML")
                                    .font(Font.body.bold())
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                
                            }.buttonStyle(.glassProminent)
                            Button{
                                modelContext.delete(empresa)
                                try? modelContext.save()
                                dismiss()
                            }label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .padding(5)
                                    .frame(width: 30, height: 30)
                            }.buttonStyle(.glass)
                        }
                    }
                }
            }

        }

        
    }

}
#Preview {
    EmpresaDetalle(
        empresa: Empresa(nombre: "Postobon", nit: "890903939"),
        selectedTab: .constant(0)
    )
        .modelContainer(for: [Empresa.self, Producto.self], inMemory: true)
        .environment(AppState())
}
