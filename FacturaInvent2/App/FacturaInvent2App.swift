//
//  FacturaInvent2App.swift
//  FacturaInvent2
//
//  Cliente del servidor local del supermercado. No hay SwiftData ni
//  CloudKit: todo el dato vive en PostgreSQL detrás de la API FastAPI.
//

import SwiftUI
import GoogleSignIn

@main
struct FacturaInvent2App: App {
    @State private var appState = AppState()

    private let serverConfig = ServerConfig.shared
    private let apiClient = APIClient.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if !serverConfig.configurado {
                    OnboardingServidorView()
                        .transition(.opacity)
                } else if !apiClient.sesionActiva {
                    LoginView()
                        .transition(.opacity)
                } else {
                    MainScreen()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: serverConfig.configurado)
            .animation(.easeInOut(duration: 0.4), value: apiClient.sesionActiva)
            .environment(appState)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .task {
                await GmailAuthManager.shared.restoreSession()
                await ColaCuadresOffline.shared.sincronizar()
            }
            .sheet(isPresented: Bindable(appState).mostrarAjustes) {
                AjustesView()
            }
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1100, height: 700)
        .commands { AppMenuCommands(appState: appState) }
        #endif
    }
}
