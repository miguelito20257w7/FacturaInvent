//
//  OnboardingServidorView.swift
//  FacturaInvent2
//
//  Primera vez que se abre la app: configurar la IP del servidor.
//

import SwiftUI

struct OnboardingServidorView: View {
    private var config = ServerConfig.shared
    @State private var urlTexto: String = ServerConfig.shared.urlServidor

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "server.rack")
                .font(.system(size: 70))
                .foregroundStyle(.tint)

            Text("Bienvenido a FacturaInvent 2")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("La app se conecta al servidor del supermercado. Escribe su dirección en la red local (por ejemplo http://192.168.1.50:8000).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                TextField("http://192.168.x.x:8000", text: $urlTexto)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    #if !targetEnvironment(macCatalyst)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    #endif

                BotonProbarConexion(urlTexto: urlTexto)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                config.urlServidor = urlTexto
                config.configurado = true
            } label: {
                Text("Continuar")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .disabled(config.estado != .conectado)

            Text("Puedes cambiar la dirección después en Ajustes.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
    }
}

/// Botón "Probar conexión" + indicador de estado. Reutilizado en Ajustes.
struct BotonProbarConexion: View {
    let urlTexto: String
    private var config = ServerConfig.shared

    init(urlTexto: String) {
        self.urlTexto = urlTexto
    }

    var body: some View {
        VStack(spacing: 10) {
            Button {
                config.urlServidor = urlTexto
                Task { await config.probarConexion() }
            } label: {
                Label("Probar conexión", systemImage: "antenna.radiowaves.left.and.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            indicadorEstado
        }
    }

    @ViewBuilder
    private var indicadorEstado: some View {
        switch config.estado {
        case .desconocido:
            EmptyView()
        case .probando:
            HStack(spacing: 8) {
                ProgressView()
                Text("Probando…").foregroundStyle(.secondary)
            }
            .font(.callout)
        case .conectado:
            Label("Conectado", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)
        case .sinConexion(let detalle):
            VStack(spacing: 2) {
                Label("Sin conexión", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.callout)
                Text(detalle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    OnboardingServidorView()
}
