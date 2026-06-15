//
//  LoginView.swift
//  FacturaInvent2
//

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var username = ""
    @State private var password = ""
    @State private var error: String?
    @State private var cargando = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.badge.key")
                .font(.system(size: 70))
                .foregroundStyle(.tint)

            Text("Iniciar sesión")
                .font(.title.bold())

            VStack(spacing: 12) {
                TextField("Usuario", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    #if !targetEnvironment(macCatalyst)
                    .textInputAutocapitalization(.never)
                    #endif
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await entrar() } }
            }
            .padding(.horizontal, 32)

            if let error {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task { await entrar() }
            } label: {
                if cargando {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Entrar")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .disabled(username.isEmpty || password.isEmpty || cargando)

            Spacer()

            Button {
                appState.mostrarAjustes = true
            } label: {
                Label("Configurar servidor", systemImage: "gearshape")
                    .font(.callout)
            }
            .padding(.bottom)
        }
        .padding()
    }

    private func entrar() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            try await APIClient.shared.login(username: username, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
