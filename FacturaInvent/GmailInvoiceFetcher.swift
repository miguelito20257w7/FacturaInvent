import Foundation

class GmailInvoiceFetcher {
    
    private let baseURL = "https://gmail.googleapis.com/gmail/v1/users/me"
    
    func fetchInvoiceEmails(accessToken: String) async throws -> [GmailMessageRef] {
        let query = "label:INBOX/EJAIVANA has:attachment (filename:zip OR filename:xml)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "\(baseURL)/messages?q=\(query)&maxResults=50")!
        let data = try await get(url: url, token: accessToken)
        let list = try JSONDecoder().decode(MessageList.self, from: data)
        return list.messages ?? []
    }
    
    func fetchMessageDetail(id: String, accessToken: String) async throws -> GmailMessageDetail {
        let url = URL(string: "\(baseURL)/messages/\(id)?format=full")!
        let data = try await get(url: url, token: accessToken)
        return try JSONDecoder().decode(GmailMessageDetail.self, from: data)
    }
    
    func fetchAttachmentData(messageId: String, attachmentId: String, accessToken: String) async throws -> Data {
        let url = URL(string: "\(baseURL)/messages/\(messageId)/attachments/\(attachmentId)")!
        let data = try await get(url: url, token: accessToken)
        let response = try JSONDecoder().decode(AttachmentBody.self, from: data)
        guard let encoded = response.data, !encoded.isEmpty else {
            throw GmailError.downloadFailed
        }
        return decodeBase64url(encoded)
    }
    
    func extractInvoiceAttachments(from message: GmailMessageDetail) -> [MessagePart] {
        let allParts = flattenParts(message.payload.parts ?? [])
        return allParts.filter { part in
            guard let filename = part.filename, !filename.isEmpty else { return false }
            let lower = filename.lowercased()
            return lower.hasSuffix(".zip") || lower.hasSuffix(".xml")
        }
    }
    
    private func flattenParts(_ parts: [MessagePart]) -> [MessagePart] {
        var result: [MessagePart] = []
        for part in parts {
            if let filename = part.filename, !filename.isEmpty {
                result.append(part)
            }
            if let subparts = part.parts {
                result += flattenParts(subparts)
            }
        }
        return result
    }
    
    func markAsRead(messageId: String, accessToken: String) async throws {
        let url = URL(string: "\(baseURL)/messages/\(messageId)/modify")!
        let body: [String: Any] = ["removeLabelIds": ["UNREAD"]]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw GmailError.downloadFailed
        }
    }
    
    private func get(url: URL, token: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw GmailError.downloadFailed
        }
        return data
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

// MARK: - Modelos
struct MessageList: Codable {
    let messages: [GmailMessageRef]?
}

struct GmailMessageRef: Codable, Identifiable {
    let id: String
    let threadId: String
}

struct GmailMessageDetail: Codable, Identifiable {
    let id: String
    let payload: MessagePayload
    let labelIds: [String]?

    var subject: String? {
        payload.headers?.first(where: { $0.name == "Subject" })?.value
    }
    var from: String? {
        payload.headers?.first(where: { $0.name == "From" })?.value
    }
    var date: String? {
        payload.headers?.first(where: { $0.name == "Date" })?.value
    }
    var isUnread: Bool {
        labelIds?.contains("UNREAD") ?? false
    }
}

struct MessagePayload: Codable {
    let headers: [MessageHeader]?
    let parts: [MessagePart]?
}

struct MessageHeader: Codable {
    let name: String
    let value: String
}

struct MessagePart: Codable {
    let mimeType: String?
    let filename: String?
    let body: AttachmentBody?
    let parts: [MessagePart]?
}

struct AttachmentBody: Codable {
    let attachmentId: String?
    let size: Int?
    let data: String?
}
