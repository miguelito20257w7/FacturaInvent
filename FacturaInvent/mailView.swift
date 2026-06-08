import SwiftUI
import SwiftData
import GoogleSignIn

struct mailView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var service = GmailInvoiceService()

    var body: some View {
        NavigationStack {
            Group {
                if !GmailAuthManager.shared.isSignedIn {
                    pantallaLogin
                } else if service.mensajes.isEmpty && service.isLoading {
                    ProgressView("Loading emails...")
                } else if service.mensajes.isEmpty, let error = service.errorMessage {
                    ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
                } else if service.mensajes.isEmpty {
                    ContentUnavailableView("No invoices found", systemImage: "tray")
                } else {
                    listaMensajes
                }
            }
            .navigationTitle("Invoices")
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

            Text("Connect your Gmail to import invoices automatically")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    try? await GmailAuthManager.shared.signIn()
                    await service.cargarCorreos()
                }
            } label: {
                Label("Sign in with Google", systemImage: "envelope")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
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
            Task {
                await service.cargarCorreos()
            }
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
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }
}
