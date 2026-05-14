//
//  welcomeScreen.swift
//  FacturaInvent
//
//  Created by Miguel Angel Salazar Garcia on 4/10/26.
//
import SwiftUI
import SwiftData


struct WelcomeScreen: View {
  @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    var body: some View {
        VStack(spacing: 50) {

            Text("welcome")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .padding(.top, 20)

            Text("welcomeDescription")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Label("Import XML invoices from DIAN", systemImage: "doc.badge.plus")
                Label("Organize your products automatically", systemImage: "list.bullet.clipboard")
                Label("Export to Excel with one tap", systemImage: "tablecells")
            }
            .foregroundStyle(.secondary)

            Button {
                isFirstLaunch = false
            }label: {
            Text("Continue")
                .font(.title)
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
            }
        .buttonStyle(.glassProminent)

        }
        #if targetEnvironment(macCatalyst)
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}
#Preview {
    VStack {
        WelcomeScreen()
            .environment(\.locale, Locale(identifier: "en"))

    }
}

#Preview {
    WelcomeScreen()
        .environment(\.locale, Locale(identifier: "es"))
}
