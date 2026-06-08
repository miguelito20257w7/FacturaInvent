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
                    Task { await descargarYEnviar(notification: .importarFacturaDesdeCorreo) }
                } label: {
                    Label("Import invoice", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal)

                Button {
                    Task { await descargarYEnviar(notification: .exportarFacturaDesdeCorreo) }
                } label: {
                    Label("Export invoice", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Invoice")
    }

    private func descargarYEnviar(notification: Notification.Name) async {
        isLoading = true
        errorMessage = nil
        do {
            let xmlURL = try await service.descargarXML(mensaje: mensaje)
            NotificationCenter.default.post(name: notification, object: xmlURL)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
