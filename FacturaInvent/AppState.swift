//
//  AppState.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//


import SwiftUI

@Observable
class AppState {
    var mostrarAgregarXML: Bool = false
    var mostrarConvertirAExcel: Bool = false
    var convirtiendoAExcel: Bool = false
    var mostrarAgregarBaseDeDatos: Bool = false
    var showCancelButton: Bool = false
}
