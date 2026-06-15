//
//  MailView.swift
//  FacturaInvent2
//
//  Portado de v1 (sin SwiftData): los correos con facturas se importan
//  directo a la API mediante la pestaña Crear.
//

import SwiftUI

struct MailView: View {
    @State private var service = GmailInvoiceService()

    var body: some View {
        NavigationStack {
            Group {
                if !GmailAuthManager.shared.isSignedIn {
                    pantallaLogin
                } else if service.mensajes.isEmpty && service.isLoading {
                    ProgressView("Cargando correos…")
                } else if service.mensajes.isEmpty, let error = service.errorMessage {
                    ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
                } else if service.mensajes.isEmpty {
                    ContentUnavailableView("No hay facturas", systemImage: "tray")
                } else {
                    listaMensajes
                }
            }
            .navigationTitle("Facturas del correo")
            .task {
                if GmailAuthManager.shared.isSignedIn {
                    await service.cargarCorreos()
                }
            }
        }
    }

    // MARK: - Login

    private var pantallaLogin: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.badge")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Conecta tu Gmail para importar las facturas automáticamente")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    try? await GmailAuthManager.shared.signIn()
                    await service.cargarCorreos()
                }
            } label: {
                Label("Iniciar sesión con Google", systemImage: "envelope")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Lista

    private var listaMensajes: some View {
        List(service.mensajes) { mensaje in
            NavigationLink {
                FacturaCorreoDetalle(mensaje: mensaje, service: service)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if mensaje.isUnread {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                        Text(mensaje.subject ?? "Sin asunto")
                            .fontWeight(mensaje.isUnread ? .bold : .regular)
                            .lineLimit(1)
                    }
                    Text(mensaje.from ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(mensaje.date ?? "")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
        }
        .refreshable {
            await service.cargarCorreos()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if service.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    GmailAuthManager.shared.signOut()
                } label: {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }
}
