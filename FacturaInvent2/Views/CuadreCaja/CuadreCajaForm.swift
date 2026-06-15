//
//  CuadreCajaForm.swift
//  FacturaInvent2
//
//  Formulario de cierre de turno. Reemplaza la hoja CUADRE DE CAJA del
//  Excel con macros. El total de denominaciones y el sobrante/faltante se
//  recalculan en tiempo real mientras el cajero digita.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class CuadreCajaFormModel {

    var numeroTurno: Int?
    var jornada: Jornada = .manana

    var ventasNetas = 0
    var entregas = 0
    var tarjetas = 0
    var bonos = 0
    var nequiQr = 0
    var factElectronicaCredito = 0
    var baseDelDia = 0
    var baseAnterior = 0

    var cantidades: [Denominacion: Int] = [:]

    /// true mientras no se haya podido cargar el turno desde el servidor
    var sinConexion = false
    var cargando = false
    var guardando = false

    var totalDenominaciones: Int {
        Denominacion.allCases.reduce(0) { $0 + (cantidades[$1] ?? 0) * $1.rawValue }
    }

    /// Fórmula verificada contra el Excel original (1010 cuadres):
    /// positivo = sobrante, negativo = faltante.
    var sobranteFaltante: Int {
        baseDelDia + entregas + tarjetas + bonos + nequiQr
            + factElectronicaCredito - ventasNetas - baseAnterior
    }

    func cargarNuevoTurno() async {
        cargando = true
        defer { cargando = false }
        do {
            await ColaCuadresOffline.shared.sincronizar()
            let turno = try await CuadreCajaEndpoint.nuevoTurno()
            numeroTurno = turno.numeroTurno
            baseAnterior = turno.baseAnterior
            sinConexion = false
        } catch {
            // Sin conexión: el cajero puede seguir; el turno y la base
            // anterior los resolverá el servidor al sincronizar.
            sinConexion = true
        }
    }

    func construirCuadre() -> CuadreCajaNuevo {
        let ahora = Date()
        let formatoFecha = DateFormatter()
        formatoFecha.dateFormat = "yyyy-MM-dd"
        formatoFecha.locale = Locale(identifier: "en_US_POSIX")
        let formatoHora = DateFormatter()
        formatoHora.dateFormat = "HH:mm:ss"
        formatoHora.locale = Locale(identifier: "en_US_POSIX")

        var cuadre = CuadreCajaNuevo(
            numeroTurno: sinConexion ? nil : numeroTurno,
            fecha: formatoFecha.string(from: ahora),
            hora: formatoHora.string(from: ahora),
            jornada: jornada.rawValue
        )
        cuadre.ventasNetas = ventasNetas
        cuadre.entregas = entregas
        cuadre.tarjetas = tarjetas
        cuadre.bonos = bonos
        cuadre.nequiQr = nequiQr
        cuadre.factElectronicaCredito = factElectronicaCredito
        cuadre.baseDelDia = baseDelDia
        cuadre.baseAnterior = sinConexion ? nil : baseAnterior
        cuadre.billetes20000 = cantidades[.b20000] ?? 0
        cuadre.billetes10000 = cantidades[.b10000] ?? 0
        cuadre.billetes5000 = cantidades[.b5000] ?? 0
        cuadre.billetes2000 = cantidades[.b2000] ?? 0
        cuadre.billetes1000 = cantidades[.b1000] ?? 0
        cuadre.monedas500 = cantidades[.m500] ?? 0
        cuadre.monedas200 = cantidades[.m200] ?? 0
        cuadre.monedas100 = cantidades[.m100] ?? 0
        cuadre.monedas50 = cantidades[.m50] ?? 0
        return cuadre
    }

    enum ResultadoGuardado {
        case enviado(CuadreCaja)
        case encolado
        case error(String)
    }

    func guardar() async -> ResultadoGuardado {
        guardando = true
        defer { guardando = false }
        let cuadre = construirCuadre()
        do {
            let registrado = try await CuadreCajaEndpoint.crear(cuadre)
            return .enviado(registrado)
        } catch APIError.sinConexion {
            ColaCuadresOffline.shared.encolar(cuadre)
            return .encolado
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func limpiar() {
        ventasNetas = 0
        entregas = 0
        tarjetas = 0
        bonos = 0
        nequiQr = 0
        factElectronicaCredito = 0
        baseDelDia = 0
        cantidades = [:]
        jornada = .manana
    }
}

// MARK: - Vista

struct CuadreCajaForm: View {
    @State private var model = CuadreCajaFormModel()
    @State private var mensajeGuardado: String?
    @State private var mostrandoConfirmacion = false

    var body: some View {
        Form {
            seccionTurno
            seccionValores
            seccionDenominaciones
            seccionResultado
            seccionGuardar
        }
        .navigationTitle("Cuadre de Caja")
        .task { await model.cargarNuevoTurno() }
        .refreshable { await model.cargarNuevoTurno() }
        .alert("Cuadre de caja", isPresented: $mostrandoConfirmacion) {
            Button("OK") { mensajeGuardado = nil }
        } message: {
            Text(mensajeGuardado ?? "")
        }
    }

    // MARK: Secciones

    private var seccionTurno: some View {
        Section("Turno") {
            HStack {
                Label("Turno", systemImage: "number")
                Spacer()
                if model.cargando {
                    ProgressView()
                } else if let turno = model.numeroTurno {
                    Text("\(turno)").bold()
                } else {
                    Text("se asigna al sincronizar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Label("Fecha", systemImage: "calendar")
                Spacer()
                Text(Date(), style: .date)
            }
            HStack {
                Label("Cajero", systemImage: "person")
                Spacer()
                Text(APIClient.shared.usuarioActual?.nombre ?? "—").bold()
            }
            Picker("Jornada", selection: $model.jornada) {
                ForEach(Jornada.allCases) { jornada in
                    Text(jornada.rawValue).tag(jornada)
                }
            }
            if model.sinConexion {
                Label("Sin conexión: el cuadre quedará en cola y se enviará después",
                      systemImage: "wifi.slash")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var seccionValores: some View {
        Section("Valores del turno") {
            CampoPesos(titulo: "Ventas netas", valor: $model.ventasNetas)
            CampoPesos(titulo: "Entregas", valor: $model.entregas)
            CampoPesos(titulo: "Tarjetas", valor: $model.tarjetas)
            CampoPesos(titulo: "Bonos", valor: $model.bonos)
            CampoPesos(titulo: "Nequi o QR", valor: $model.nequiQr)
            CampoPesos(titulo: "Fact. electrónica crédito", valor: $model.factElectronicaCredito)
            CampoPesos(titulo: "Base del día", valor: $model.baseDelDia)
            if model.sinConexion {
                CampoPesos(titulo: "Base anterior", valor: $model.baseAnterior)
            } else {
                HStack {
                    Text("Base anterior")
                    Spacer()
                    Text(model.baseAnterior.pesos)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var seccionDenominaciones: some View {
        Section {
            ForEach(Denominacion.allCases) { denominacion in
                FilaDenominacion(
                    denominacion: denominacion,
                    cantidad: Binding(
                        get: { model.cantidades[denominacion] ?? 0 },
                        set: { model.cantidades[denominacion] = $0 }
                    )
                )
            }
            HStack {
                Text("Total base").bold()
                Spacer()
                Text(model.totalDenominaciones.pesos)
                    .bold()
                    .contentTransition(.numericText())
                    .animation(.default, value: model.totalDenominaciones)
            }
        } header: {
            Text("Denominaciones")
        } footer: {
            Text("Cuenta los billetes y monedas de la caja; el total se actualiza solo.")
        }
    }

    private var seccionResultado: some View {
        Section {
            VStack(spacing: 6) {
                Text(model.sobranteFaltante >= 0 ? "SOBRANTE" : "FALTANTE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(model.sobranteFaltante.pesos)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(model.sobranteFaltante >= 0 ? .green : .red)
                    .contentTransition(.numericText())
                    .animation(.default, value: model.sobranteFaltante)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private var seccionGuardar: some View {
        Section {
            Button {
                Task { await guardar() }
            } label: {
                if model.guardando {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Registrar cuadre")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(model.guardando)
        }
    }

    private func guardar() async {
        let resultado = await model.guardar()
        switch resultado {
        case .enviado(let cuadre):
            mensajeGuardado = "Turno \(cuadre.numeroTurno) registrado. "
                + (cuadre.sobranteFaltante >= 0
                    ? "Sobrante: \(cuadre.sobranteFaltante.pesos)"
                    : "Faltante: \((-cuadre.sobranteFaltante).pesos)")
            model.limpiar()
            await model.cargarNuevoTurno()
        case .encolado:
            mensajeGuardado = "Sin conexión: el cuadre quedó guardado en el dispositivo y se enviará automáticamente cuando vuelva la conexión."
            model.limpiar()
        case .error(let mensaje):
            mensajeGuardado = mensaje
        }
        mostrandoConfirmacion = true
    }
}

// MARK: - Componentes

/// Campo de pesos colombianos: muestra el valor formateado y abre teclado numérico.
struct CampoPesos: View {
    let titulo: String
    @Binding var valor: Int

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            TextField("$ 0", value: $valor, format: .number.grouping(.automatic))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
                #if !targetEnvironment(macCatalyst)
                .keyboardType(.numberPad)
                #endif
        }
    }
}

struct FilaDenominacion: View {
    let denominacion: Denominacion
    @Binding var cantidad: Int

    var body: some View {
        HStack {
            Image(systemName: denominacion.esBillete ? "banknote" : "centsign.circle")
                .foregroundStyle(denominacion.esBillete ? .green : .orange)
                .frame(width: 26)
            Text(denominacion.rawValue.pesos)
                .monospacedDigit()
            Spacer()
            TextField("0", value: $cantidad, format: .number)
                .multilineTextAlignment(.trailing)
                .frame(width: 64)
                #if !targetEnvironment(macCatalyst)
                .keyboardType(.numberPad)
                #endif
            Text((cantidad * denominacion.rawValue).pesos)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationStack { CuadreCajaForm() }
}
