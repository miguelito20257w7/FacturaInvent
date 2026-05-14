//
//  FacturaInventApp.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//

import SwiftUI
import SwiftData

@main

struct FacturaInventApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Empresa.self,
            Producto.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do{
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        }catch {
            print("Error detallado: \(error)")
            print("Error localizado: \(error.localizedDescription)")
            if let swiftDataError = error as? SwiftData.SwiftDataError {
                print("SwiftData error: \(swiftDataError)")
            }
            fatalError("Error initializing ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group{
                if isFirstLaunch {
                    WelcomeScreen()
                        .transition(.opacity)
                } else {
                    MainScreen()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isFirstLaunch)
            .environment(appState)
        }
        .modelContainer(sharedModelContainer)
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1000, height: 650)
        .commands { AppMenuCommands() }
        #endif
    }
}
