//
//  AgregarXMLDesdeCorreo.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 7/06/26.
//


import SwiftUI
import SwiftData

struct AgregarXMLDesdeCorreo: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let xmlURL: URL

    // Reutilizamos AgregarXML pasándole la URL directamente
    @State private var agregarXML: AgregarXML? = nil

    var body: some View {
        AgregarXML(selectedTab: .constant(1))
            .onAppear {
                // Pequeño delay para que la View esté lista
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Buscamos la instancia y llamamos parsearFacturaDesdeURL
                    NotificationCenter.default.post(
                        name: .parsearXMLDesdeCorreo,
                        object: xmlURL
                    )
                }
            }
    }
}

extension Notification.Name {
    static let parsearXMLDesdeCorreo = Notification.Name("parsearXMLDesdeCorreo")
}