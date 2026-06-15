import SwiftUI
import PDFKit
import QuickLook

struct FacturaCorreoDetalle: View {
    @Environment(\.dismiss) private var dismiss
    let mensaje: GmailMessageDetail
    let service: GmailInvoiceService

    @State private var factura: ExtractedInvoice?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var previewURL: URL?

    var body: some View {
        VStack(spacing: 20) {
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

            // Visor de la factura (PDF)
            visorFactura
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                Task { await enviar(notification: .importarFacturaDesdeCorreo) }
            } label: {
                Label("Import invoice", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
            .disabled(isLoading)

            Button {
                Task { await enviar(notification: .exportarFacturaDesdeCorreo) }
            } label: {
                Label("Export invoice", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .padding(.horizontal)
            .disabled(isLoading)

            if let pdfURL = factura?.pdfURL {
                Button {
                    previewURL = pdfURL
                } label: {
                    Label("Open PDF in external source", systemImage: "arrow.up.forward.app")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Invoice")
        .task { await cargarFactura() }
        .quickLookPreview($previewURL)
    }

    // MARK: - Visor

    @ViewBuilder
    private var visorFactura: some View {
        if let pdfURL = factura?.pdfURL {
            PDFKitView(url: pdfURL)
        } else if isLoading {
            ProgressView("Loading invoice...")
        } else if let error = errorMessage {
            ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
        } else {
            ContentUnavailableView("No preview available", systemImage: "doc")
        }
    }

    // MARK: - Acciones

    private func cargarFactura() async {
        guard factura == nil else { return }
        isLoading = true
        errorMessage = nil
        do {
            factura = try await service.descargarFactura(mensaje: mensaje)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func enviar(notification: Notification.Name) async {
        isLoading = true
        errorMessage = nil
        do {
            // Reutiliza la descarga del visor si ya está lista; si no, descarga ahora.
            let xmlURL: URL
            if let cached = factura?.xmlURL {
                xmlURL = cached
            } else {
                xmlURL = try await service.descargarXML(mensaje: mensaje)
            }
            NotificationCenter.default.post(name: notification, object: xmlURL)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url {
            uiView.document = PDFDocument(url: url)
        }
    }
}
