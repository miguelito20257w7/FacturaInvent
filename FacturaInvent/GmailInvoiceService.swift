import Foundation
import SwiftUI

@MainActor
class GmailInvoiceService: ObservableObject {
    
    @Published var mensajes: [GmailMessageDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetcher = GmailInvoiceFetcher()
    
    func cargarCorreos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let token = try await GmailAuthManager.shared.accessToken()
            let refs = try await fetcher.fetchInvoiceEmails(accessToken: token)
            
            var detalles: [GmailMessageDetail] = []
            for ref in refs {
                let detalle = try await fetcher.fetchMessageDetail(id: ref.id, accessToken: token)
                detalles.append(detalle)
            }
            
            mensajes = detalles
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func descargarXML(mensaje: GmailMessageDetail) async throws -> URL {
        let token = try await GmailAuthManager.shared.accessToken()
        let adjuntos = fetcher.extractInvoiceAttachments(from: mensaje)
        
        guard let adjunto = adjuntos.first, let filename = adjunto.filename else {
            throw GmailError.noAttachments
        }
        
        let attachData: Data
        if let attachmentId = adjunto.body?.attachmentId {
            attachData = try await fetcher.fetchAttachmentData(
                messageId: mensaje.id,
                attachmentId: attachmentId,
                accessToken: token
            )
        } else if let inlineData = adjunto.body?.data, !inlineData.isEmpty {
            attachData = decodeBase64url(inlineData)
        } else {
            throw GmailError.downloadFailed
        }
        
        let extracted: ExtractedInvoice
        if filename.lowercased().hasSuffix(".zip") {
            extracted = try InvoiceFileManager.saveAndExtract(data: attachData, filename: filename)
        } else {
            extracted = try InvoiceFileManager.saveXML(data: attachData, filename: filename)
        }
        
        guard let xmlURL = extracted.xmlURL else {
            throw GmailError.noAttachments
        }
        
        return xmlURL
    }
    
    private func decodeBase64url(_ string: String) -> Data {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let rem = base64.count % 4
        if rem > 0 { base64 += String(repeating: "=", count: 4 - rem) }
        return Data(base64Encoded: base64) ?? Data()
    }
}