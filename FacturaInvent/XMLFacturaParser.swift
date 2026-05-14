//
//  XMLFacturaParser.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//

import Foundation

class XMLFacturaParser: NSObject, XMLParserDelegate {

    var productos: [(codigo: String, codigoBarras: String, nombre: String, cantidad: String, precioSinIVA: String, tieneDescuento: Bool, porcentajeDescuento: Double)] = []

    var nit: String = ""
    var nombreEmpresa: String = ""

    private var codigoBarrasActual = ""
    private var codigoFacturaActual = ""
    private var nombreActual = ""
    private var cantidadActual = ""
    private var precioActual = ""
    private var tieneDescuentoTemp = false
    private var lineExtensionActual = ""

    private var etiquetaActual = ""
    private var dentroDeItem = false
    private var dentroDeInvoiceLine = false
    private var dentroDeSellerID = false
    private var dentroDeStandardID = false
    private var dentroDeAdditionalID = false
    private var dentroDeSupplierParty = false
    private var dentroDeSenderParty = false
    private var dentroDePrice = false
    private var schemeIDActual = ""
    private var dentroDeAllowanceCharge = false
    private var cdataActual = ""
    
    
    // Implementa este delegate method (Foundation lo llama automáticamente para CDATA)
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let xmlString = String(data: CDATABlock, encoding: .utf8) else { return }
        
        // El CDATA contiene el Invoice real — lo parseamos por separado
        guard xmlString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<?xml") ||
              xmlString.contains("<Invoice") else { return }
        
        guard let data = xmlString.data(using: .utf8) else { return }
        let subParser = XMLParser(data: data)
        subParser.delegate = self
        subParser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        etiquetaActual = elementName
        if elementName == "InvoiceLine" { dentroDeInvoiceLine = true }
        if elementName == "Item" { dentroDeItem = true }
        if elementName == "Price" && dentroDeInvoiceLine { dentroDePrice = true }
        if elementName == "SellersItemIdentification" { dentroDeSellerID = true }
        if elementName == "StandardItemIdentification" { dentroDeStandardID = true }
        if elementName == "AdditionalItemIdentification" { dentroDeAdditionalID = true }
        if elementName == "AccountingSupplierParty" { dentroDeSupplierParty = true}
        if elementName == "SenderParty" {dentroDeSenderParty = true}
        if elementName == "ID" {schemeIDActual = attributeDict["schemeID"] ?? ""}
        if elementName == "AllowanceCharge" {dentroDeAllowanceCharge = true}
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // aquí capturamos los valores
        // quitamos espacios y saltos de linea del texto que encontró el parser
        let texto = string.trimmingCharacters(in: .whitespacesAndNewlines)
        // si el texto está vacío no hacemos nada y salimos
        guard !texto.isEmpty else { return }
       
        if (dentroDeSupplierParty || dentroDeSenderParty) && etiquetaActual == "CompanyID" && nit.isEmpty { nit += texto }
        if (dentroDeSupplierParty || dentroDeSenderParty) && etiquetaActual == "RegistrationName" && nombreEmpresa.isEmpty { nombreEmpresa += texto }
        // solo nos importa lo que está dentro de un InvoiceLine
        // (aquí están los productos, afuera hay otros datos que no necesitamos)
        if dentroDeInvoiceLine {
            
            // revisamos en qué etiqueta está parado el parser en este momento
            switch etiquetaActual {
                
            case "InvoicedQuantity":
                // encontramos la cantidad del producto
                cantidadActual += texto
            case "ChargeIndicator":
                if dentroDeAllowanceCharge {
                    if texto == "false" { tieneDescuentoTemp = true }
                    else if texto == "true" { tieneDescuentoTemp = false }
                }
            case "LineExtensionAmount":
                if dentroDeInvoiceLine {
                    lineExtensionActual += texto
                }
            case "Description":
                if dentroDeItem { nombreActual += texto.replacingOccurrences(of: "|", with: "").trimmingCharacters(in: .whitespaces) }

            case "ID":
                if dentroDeSellerID {
                    codigoFacturaActual += texto
                } else if dentroDeStandardID {
                    if schemeIDActual == "010" {
                        codigoBarrasActual += texto  // EAN real
                    } else if schemeIDActual == "999" {
                        codigoFacturaActual += texto  // código interno
                    }
                } else if dentroDeAdditionalID && codigoFacturaActual.isEmpty {
                    codigoFacturaActual += texto
                }
            default:
                // cualquier otra etiqueta la ignoramos
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Item" {
            // salimos del item
            dentroDeItem = false
        }
        if elementName == "SellersItemIdentification" { dentroDeSellerID = false }
        if elementName == "StandardItemIdentification" {dentroDeStandardID = false}
        if elementName == "AdditionalItemIdentification" { dentroDeAdditionalID = false }
        if elementName == "SenderParty" { dentroDeSenderParty = false }
        if elementName == "Price" { dentroDePrice = false }
        if elementName == "AllowanceCharge" { dentroDeAllowanceCharge = false }
        
        let cantidad = Double(cantidadActual) ?? 1
        let lineExtension = Double(lineExtensionActual) ?? 0
        let precioUnitario = cantidad > 0 ? lineExtension / cantidad : 0
        precioActual = String(format: "%.2f", precioUnitario)
        
        if elementName == "InvoiceLine" {
            // el parser terminó de leer un producto completo
            // lo guardamos en el array
            let producto = (
                codigo: codigoFacturaActual,
                codigoBarras: codigoBarrasActual,
                nombre: nombreActual,
                cantidad: cantidadActual,
                precioSinIVA: precioActual,
                tieneDescuento: tieneDescuentoTemp,
                porcentajeDescuento: 0.0
            )
            productos.append(producto)

            codigoFacturaActual = ""
            codigoBarrasActual = ""
            nombreActual = ""
            cantidadActual = ""
            precioActual = ""
            dentroDeInvoiceLine = false
            dentroDeItem = false
            tieneDescuentoTemp = false
            lineExtensionActual = ""
            
        }
    }
    
}

