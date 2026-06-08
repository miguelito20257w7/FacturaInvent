import Foundation
import ZIPFoundation

class InvoiceFileManager {
    
    // Directorio: Documents/Facturas/
    static var invoicesDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Facturas", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    // Guarda un ZIP, lo descomprime y retorna XML y PDF
    static func saveAndExtract(data: Data, filename: String) throws -> ExtractedInvoice {
        let folder = invoicesDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let zipURL = folder.appendingPathComponent(filename)
        try data.write(to: zipURL)
        
        try FileManager.default.unzipItem(at: zipURL, to: folder)
        
        let contents = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )
        
        let xmlURL = contents.first(where: { $0.pathExtension.lowercased() == "xml" })
        let pdfURL = contents.first(where: { $0.pathExtension.lowercased() == "pdf" })
        
        // Eliminar el ZIP, ya no se necesita
        try? FileManager.default.removeItem(at: zipURL)
        
        return ExtractedInvoice(folderURL: folder, xmlURL: xmlURL, pdfURL: pdfURL)
    }
    
    // Para XMLs que vienen directo sin ZIP
    static func saveXML(data: Data, filename: String) throws -> ExtractedInvoice {
        let folder = invoicesDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let xmlURL = folder.appendingPathComponent(filename)
        try data.write(to: xmlURL)
        
        return ExtractedInvoice(folderURL: folder, xmlURL: xmlURL, pdfURL: nil)
    }
}

struct ExtractedInvoice {
    let folderURL: URL
    let xmlURL: URL?
    let pdfURL: URL?
    
    var hasXML: Bool { xmlURL != nil }
    var hasPDF: Bool { pdfURL != nil }
}