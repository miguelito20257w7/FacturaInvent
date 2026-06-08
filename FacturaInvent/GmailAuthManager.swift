import GoogleSignIn
import Foundation

@MainActor
class GmailAuthManager: ObservableObject {
    
    static let shared = GmailAuthManager()
    
    @Published var isSignedIn = false
    @Published var userEmail: String?
    
    private let clientID = "279081770593-vvj79v3s7onugv26mslcfnv40sdpe77p.apps.googleusercontent.com"
    private let scopes = ["https://www.googleapis.com/auth/gmail.readonly"]
    
    func signIn() async throws {
        guard let vc = UIApplication.shared.topViewController else {
            throw GmailError.notSignedIn
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: vc,
            hint: nil,
            additionalScopes: scopes
        )
        
        isSignedIn = true
        userEmail = result.user.profile?.email
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        userEmail = nil
    }
    
    func accessToken() async throws -> String {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw GmailError.notSignedIn
        }
        try await user.refreshTokensIfNeeded()
        return user.accessToken.tokenString
    }
    
    func restoreSession() async {
        try? await GIDSignIn.sharedInstance.restorePreviousSignIn()
        isSignedIn = GIDSignIn.sharedInstance.currentUser != nil
        userEmail = GIDSignIn.sharedInstance.currentUser?.profile?.email
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        guard let windowScene = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return nil }
        
        var top = window.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

enum GmailError: LocalizedError {
    case notSignedIn
    case downloadFailed
    case noAttachments
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "No hay sesión de Gmail activa"
        case .downloadFailed: return "Error al descargar el adjunto"
        case .noAttachments: return "No se encontraron facturas adjuntas"
        }
    }
}