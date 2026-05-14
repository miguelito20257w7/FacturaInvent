//
//  exportarExcel.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/12/26.
//

import Foundation
import ZIPFoundation

func exportarExcel(productos: [ProductoImport]) -> URL? {
    let filas = productos.map { p -> (codigo: String, precio: String, cantidad: Int) in
        let cantidadInt = Int(Double(p.cantidad) ?? 0)
        let totalPaquetes = cantidadInt * p.cantidadPaquetes
        let codigo = p.codigoInterno.isEmpty ? "Sin código" : p.codigoInterno
        let precioRaw = Double(p.precioSinIVA.replacingOccurrences(of: ",", with: ".")) ?? 0
        let precioConDescuento = (p.tieneDescuento && p.porcentajeDescuento > 0)
            ? precioRaw * (1 - p.porcentajeDescuento / 100)
            : precioRaw
        let paquetes = p.cantidadPaquetes > 0 ? p.cantidadPaquetes : 1
        let precioUnidad = precioConDescuento / Double(paquetes)
        let precioFormateado = String(format: "%.2f", precioUnidad)
        print("exportarExcel → \(p.codigoInterno) | precioSinIVA: \(p.precioSinIVA) | descuento: \(p.tieneDescuento ? p.porcentajeDescuento : 0)% | cantidadPaquetes: \(p.cantidadPaquetes) | precioUnidad: \(precioFormateado)")
        return (codigo: codigo, precio: p.precioSinIVA.isEmpty ? "0.00" : precioFormateado, cantidad: totalPaquetes)
    }
    return generarXLSX(filas: filas)
}

// MARK: - Generación XLSX

private func generarXLSX(filas: [(codigo: String, precio: String, cantidad: Int)]) -> URL? {
    let tempDir = FileManager.default
        .temporaryDirectory
        .appendingPathComponent(UUID().uuidString)

    do {
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let xlDir         = tempDir.appendingPathComponent("xl")
        let worksheetsDir = xlDir.appendingPathComponent("worksheets")
        let relsDir       = tempDir.appendingPathComponent("_rels")
        let xlRelsDir     = xlDir.appendingPathComponent("_rels")

        for dir in [xlDir, worksheetsDir, relsDir, xlRelsDir] {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // MARK: [Content_Types].xml  — incluye styles
        let contentTypes = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>\
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\
        <Default Extension="xml" ContentType="application/xml"/>\
        <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>\
        <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>\
        <Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>\
        <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>\
        </Types>
        """
        try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)

        // MARK: _rels/.rels
        let rels = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>\
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>\
        </Relationships>
        """
        try rels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)

        // MARK: xl/workbook.xml
        let workbook = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>\
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">\
        <sheets><sheet name="Productos" sheetId="1" r:id="rId1"/></sheets>\
        </workbook>
        """
        try workbook.write(to: xlDir.appendingPathComponent("workbook.xml"), atomically: true, encoding: .utf8)

        // MARK: xl/_rels/workbook.xml.rels  — incluye styles
        let workbookRels = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>\
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>\
        <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>\
        <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>\
        </Relationships>
        """
        try workbookRels.write(to: xlRelsDir.appendingPathComponent("workbook.xml.rels"), atomically: true, encoding: .utf8)

        // MARK: xl/styles.xml
        // xf índice 0 → formato general (headers y cantidad)
        // xf índice 1 → numFmtId 164 = "0.00"  (precio, siempre 2 decimales)
        let styles = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>\
        <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">\
        <numFmts count="1">\
        <numFmt numFmtId="164" formatCode="0.00"/>\
        </numFmts>\
        <fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>\
        <fills count="2">\
        <fill><patternFill patternType="none"/></fill>\
        <fill><patternFill patternType="gray125"/></fill>\
        </fills>\
        <borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>\
        <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>\
        <cellXfs count="2">\
        <xf numFmtId="0"   fontId="0" fillId="0" borderId="0" xfId="0"/>\
        <xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>\
        </cellXfs>\
        </styleSheet>
        """
        try styles.write(to: xlDir.appendingPathComponent("styles.xml"), atomically: true, encoding: .utf8)

        // MARK: Shared strings (deduplicadas)
        var stringIndex: [String: Int] = [:]
        var strings: [String] = []

        func addSharedString(_ s: String) -> Int {
            if let idx = stringIndex[s] { return idx }
            let idx = strings.count
            strings.append(s)
            stringIndex[s] = idx
            return idx
        }

        let codigoIndices = filas.map { addSharedString($0.codigo) }

        let sharedStringsXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><sst xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" count=\"\(filas.count)\" uniqueCount=\"\(strings.count)\">\(strings.map { "<si><t>\($0.xmlEscaped)</t></si>" }.joined())</sst>"
        try sharedStringsXML.write(to: xlDir.appendingPathComponent("sharedStrings.xml"), atomically: true, encoding: .utf8)

        // MARK: Sheet  — sin encabezado, datos desde fila 1
        var rows = ""

        for (i, fila) in filas.enumerated() {
            let rowNum = i + 1
            rows += "<row r=\"\(rowNum)\"><c r=\"A\(rowNum)\" t=\"s\"><v>\(codigoIndices[i])</v></c><c r=\"B\(rowNum)\" s=\"1\"><v>\(fila.precio)</v></c><c r=\"C\(rowNum)\"><v>\(fila.cantidad)</v></c></row>"
        }

        let sheet = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><sheetData>\(rows)</sheetData></worksheet>"
        try sheet.write(to: worksheetsDir.appendingPathComponent("sheet1.xml"), atomically: true, encoding: .utf8)

        // MARK: Nombre con fecha
        let fecha = DateFormatter()
        fecha.dateFormat = "yyyy-MM-dd"
        let nombreArchivo = "productos-\(fecha.string(from: Date())).xlsx"

        let outputURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(nombreArchivo)

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }

        let archive: Archive
        do {
            archive = try Archive(url: outputURL, accessMode: .create)
        } catch {
            print("❌ No se pudo crear el archivo ZIP: \(error)")
            return nil
        }

        let archivosOrdenados: [(String, URL)] = [
            ("[Content_Types].xml",        tempDir.appendingPathComponent("[Content_Types].xml")),
            ("_rels/.rels",                relsDir.appendingPathComponent(".rels")),
            ("xl/workbook.xml",            xlDir.appendingPathComponent("workbook.xml")),
            ("xl/_rels/workbook.xml.rels", xlRelsDir.appendingPathComponent("workbook.xml.rels")),
            ("xl/styles.xml",              xlDir.appendingPathComponent("styles.xml")),
            ("xl/sharedStrings.xml",       xlDir.appendingPathComponent("sharedStrings.xml")),
            ("xl/worksheets/sheet1.xml",   worksheetsDir.appendingPathComponent("sheet1.xml")),
        ]

        print("📁 Archivos a comprimir:")
        for (relativePath, url) in archivosOrdenados {
            print("   → \(relativePath)")
            try archive.addEntry(with: relativePath, fileURL: url)
        }

        try FileManager.default.removeItem(at: tempDir)
        print("✅ Excel generado: \(outputURL.path)")
        return outputURL

    } catch {
        print("❌ Error generando XLSX: \(error)")
        return nil
    }
}

// MARK: - Helpers

private extension String {
    var xmlEscaped: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
