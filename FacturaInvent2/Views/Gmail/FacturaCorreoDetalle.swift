//
//  FacturaCorreoDetalle.swift
//  FacturaInvent2
//
//  Portado de v1. Descarga el XML del correo y lo manda a la pestaña
//  Crear, que importa los productos a la API.
//

import SwiftUI

struct FacturaCorreoDetalle: View {
    @Environment(\.dismiss) private var dismiss
    let mensaje: GmailMessageDetail
    let service: GmailInvoiceService

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Descargando factura…")
            } else if let error = errorMessage {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Label(mensaje.subject ?? "Sin asunto", systemImage: "envelope")
                        .font(.headline)
                    Label(mensaje.from ?? "", systemImage: "person")
                        .foregroundStyle(.secondary)
                    Label(mensaje.date ?? "", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                Button {
                    Task { await descargarEImportar() }
                } label: {
                    Label("Importar factura", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Factura")
    }

    private func descargarEImportar() async {
        isLoading = true
        errorMessage = nil
        do {
            let xmlURL = try await service.descargarXML(mensaje: mensaje)
            NotificationCenter.default.post(name: .importarFacturaDesdeCorreo, object: xmlURL)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
