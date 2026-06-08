import SwiftUI

struct FacturaCorreoDetalle: View {
    @Environment(\.modelContext) private var modelContext
    let mensaje: GmailMessageDetail
    let service: GmailInvoiceService

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var xmlURL: URL?
    
    // Necesitamos una instancia de AgregarXML para llamar parsearFacturaDesdeURL
    // Lo hacemos con un @State que se activa al descargar
    @State private var mostrarImport = false

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Downloading invoice...")
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
                    Task { await descargarYParsear() }
                } label: {
                    Label("Import invoice", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Invoice")
        .sheet(isPresented: $mostrarImport) {
            if let url = xmlURL {
                AgregarXMLDesdeCorreo(xmlURL: url)
            }
        }
    }

    private func descargarYParsear() async {
        isLoading = true
        errorMessage = nil
        do {
            xmlURL = try await service.descargarXML(mensaje: mensaje)
            mostrarImport = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}