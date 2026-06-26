//
//  TokenStore.swift
//  FacturaInvent v2 client foundation
//
//  Keychain-backed storage for JWT access + refresh tokens.
//

import Foundation
import Security

/// Thread-safe token storage. Access token is held in memory + Keychain;
/// refresh token lives only in the Keychain.
actor TokenStore {
    static let shared = TokenStore()

    private let service = "dev.swiftydevs.facturainvent.tokens"
    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"

    private var cachedAccess: String?

    init() {
        cachedAccess = Self.read(service: service, account: accessKey)
    }

    var accessToken: String? { cachedAccess }
    var refreshToken: String? { Self.read(service: service, account: refreshKey) }

    func save(_ tokens: TokenPair) {
        cachedAccess = tokens.accessToken
        Self.write(tokens.accessToken, service: service, account: accessKey)
        Self.write(tokens.refreshToken, service: service, account: refreshKey)
    }

    func updateAccessToken(_ token: String) {
        cachedAccess = token
        Self.write(token, service: service, account: accessKey)
    }

    func clear() {
        cachedAccess = nil
        Self.delete(service: service, account: accessKey)
        Self.delete(service: service, account: refreshKey)
    }

    var isAuthenticated: Bool { cachedAccess != nil }

    // MARK: - Keychain primitives

    private static func write(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private static func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
