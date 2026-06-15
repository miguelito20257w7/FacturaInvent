//
//  AjustesView.swift
//  FacturaInvent2
//
//  Configuración del servidor accesible en cualquier momento:
//  - URL del servidor (persistida en UserDefaults, efecto inmediato)
//  - Probar conexión contra GET /health
//  - Estado actual de la conexión
//  - Sesión y cola offline
//

import SwiftUI

struct AjustesView: View {
    @Environment(\.dismiss) private var dismiss
    private var config = ServerConfig.shared
    private var api = APIClient.shared
    private var cola = ColaCuadresOffline.shared

    @State private var urlTexto: String = ServerConfig.shared.urlServidor
    @State private var mensajeSync: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("http://192.168.x.x:8000", text: $urlTexto)
                        .autocorrectionDisabled()
                        #if !targetEnvironment(macCatalyst)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        #endif
                    Button {
                        aplicarURL()
                        Task { await config.probarConexion() }
                    } label: {
                        Label("Probar conexión", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    estadoConexion
                } header: {
                    Text("Servidor")
                } footer: {
                    Text("El cambio aplica de inmediato, sin reiniciar la app. En desarrollo usa http://localhost:8000.")
                }

                Section("Sesión") {
                    if let usuario = api.usuarioActual {
                        FilaDato("Usuario", usuario.nombre)
                        FilaDato("Rol", usuario.rol)
                        Button("Cerrar sesión", role: .destructive) {
                            api.logout()
                            dismiss()
                        }
                    } else {
                        Text("Sin sesión activa")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    if cola.pendientes.isEmpty {
                        Label("No hay cuadres pendientes", systemImage: "checkmark.circle")
                            .foregroundStyle(.secondary)
                    } else {
                        Label("\(cola.pendientes.count) cuadre(s) sin sincronizar", systemImage: "clock.arrow.2.circlepath")
                            .foregroundStyle(.orange)
                        Button {
                            Task {
                                let enviados = await cola.sincronizar()
                                mensajeSync = enviados > 0
                                    ? "Se sincronizaron \(enviados) cuadre(s)."
                                    : "No se pudo sincronizar. Revisa la conexión."
                            }
                        } label: {
                            Label("Sincronizar ahora", systemImage: "arrow.clockwise")
                        }
                        if let mensajeSync {
                            Text(mensajeSync)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Cuadres offline")
                }

                Section("Gmail") {
                    if GmailAuthManager.shared.isSignedIn {
                        FilaDato("Cuenta", GmailAuthManager.shared.userEmail ?? "conectada")
                        Button("Desconectar Gmail", role: .destructive) {
                            GmailAuthManager.shared.signOut()
                        }
                    } else {
                        Text("Sin cuenta conectada — conéctala en la pestaña Mail")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            #if !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        aplicarURL()
                        dismiss()
                    }
                }
            }
        }
        .task {
            await config.probarConexion()
        }
    }

    private func aplicarURL() {
        // Cambio en caliente: APIClient lee ServerConfig en cada petición.
        config.urlServidor = urlTexto
    }

    @ViewBuilder
    private var estadoConexion: some View {
        HStack {
            Text("Estado")
            Spacer()
            switch config.estado {
            case .desconocido:
                Text("—").foregroundStyle(.secondary)
            case .probando:
                ProgressView()
            case .conectado:
                Label("Conectado", systemImage: "circle.fill")
                    .foregroundStyle(.green)
                    .labelStyle(EstadoLabelStyle())
            case .sinConexion:
                Label("Sin conexión", systemImage: "circle.fill")
                    .foregroundStyle(.red)
                    .labelStyle(EstadoLabelStyle())
            }
        }
    }
}

/// Punto de color pequeño + texto, estilo indicador de estado.
private struct EstadoLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon.font(.system(size: 9))
            configuration.title
        }
    }
}

#Preview {
    AjustesView()
}
