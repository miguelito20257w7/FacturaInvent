//
//  CashViewModel.swift
//  FacturaInvent v2 client foundation
//
//  Bridge view model for the cash-register module: device-binding setup,
//  cashier login, and the shift lifecycle. NOT compiled here.
//
//  Token handling: the device-binding setup uses the short-lived admin_device
//  token (stored transiently, then cleared after binding — never persisted on
//  the device). Cashier login stores the register session token for shift calls.
//

import Foundation

@MainActor
@Observable
final class CashViewModel {
    var registers: [CashRegisterDTO] = []
    var shifts: [ShiftDTO] = []
    var sessionRegisterId: UUID?
    var isLoading = false
    var errorMessage: String?

    private let client = APIClient.shared
    private let tokens = TokenStore.shared

    // MARK: - Device binding setup (admin, one-time per device)

    /// Step 1+2: authenticate the admin ephemerally and list the org's registers.
    func beginDeviceSetup(adminEmail: String, adminPassword: String) async throws -> [CashRegisterDTO] {
        let token: AccessTokenResponse = try await client.post(
            "/auth/admin-device-login",
            body: AdminDeviceLoginRequest(email: adminEmail, password: adminPassword),
            authorized: false
        )
        await tokens.updateAccessToken(token.accessToken)
        let regs: [CashRegisterDTO] = try await client.get("/cash-registers")
        registers = regs
        return regs
    }

    /// Step 2 (optional): create a new register during setup.
    func createRegister(name: String?, username: String, password: String) async throws -> CashRegisterDTO {
        try await client.post(
            "/cash-registers",
            body: CashRegisterCreate(name: name, username: username, password: password)
        )
    }

    /// Step 3: bind this device to a register, then drop the admin session.
    func bindDevice(cashRegisterId: UUID, deviceFingerprint: String, deviceName: String?) async throws -> DeviceBindingDTO {
        let binding: DeviceBindingDTO = try await client.post(
            "/device-bindings",
            body: DeviceBindRequest(
                cashRegisterId: cashRegisterId,
                deviceFingerprint: deviceFingerprint,
                deviceName: deviceName
            )
        )
        await tokens.clear()  // admin credentials never persist on the device
        return binding
    }

    // MARK: - Cashier session

    /// Step 4: cashier logs in with register credentials on a bound device.
    func cashierLogin(deviceFingerprint: String, username: String, password: String) async throws {
        let session: CashierTokenDTO = try await client.post(
            "/auth/cashier-login",
            body: CashierLoginRequest(
                deviceFingerprint: deviceFingerprint, username: username, password: password
            ),
            authorized: false
        )
        await tokens.updateAccessToken(session.accessToken)
        sessionRegisterId = session.cashRegisterId
    }

    // MARK: - Shifts

    func openShift(_ request: ShiftOpenRequest) async throws -> ShiftDTO {
        try await client.post("/shifts", body: request)
    }

    func closeShift(id: UUID, _ request: ShiftCloseRequest) async throws -> ShiftDTO {
        try await client.post("/shifts/\(id.uuidString.lowercased())/close", body: request)
    }

    func loadShifts(cashRegisterId: UUID? = nil, status: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        var items: [String] = []
        if let cashRegisterId { items.append("cash_register_id=\(cashRegisterId.uuidString.lowercased())") }
        if let status { items.append("status=\(status)") }
        let path = items.isEmpty ? "/shifts" : "/shifts?\(items.joined(separator: "&"))"
        do { shifts = try await client.get(path) } catch { errorMessage = error.localizedDescription }
    }
}

// MARK: - DTOs (mirror app/schemas/cash.py)

struct CashRegisterDTO: Decodable, Identifiable {
    let id: UUID
    let organizationId: UUID
    let name: String?
    let username: String
    let isActive: Bool
    let createdAt: Date
}

struct CashRegisterCreate: Encodable {
    let name: String?
    let username: String
    let password: String
}

struct AdminDeviceLoginRequest: Encodable {
    let email: String
    let password: String
}

struct DeviceBindRequest: Encodable {
    let cashRegisterId: UUID
    let deviceFingerprint: String
    let deviceName: String?
}

struct DeviceBindingDTO: Decodable, Identifiable {
    let id: UUID
    let cashRegisterId: UUID
    let deviceFingerprint: String
    let deviceName: String?
    let isActive: Bool
    let boundAt: Date
}

struct CashierLoginRequest: Encodable {
    let deviceFingerprint: String
    let username: String
    let password: String
}

struct CashierTokenDTO: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let cashRegisterId: UUID
    let organizationId: UUID
}

struct PaymentMethodIn: Encodable {
    let method: String        // cash | card | nequi_qr | bonos
    let amount: Decimal
}

struct DenominationIn: Encodable {
    let denomination: Int
    let quantity: Int
}

struct ShiftOpenRequest: Encodable {
    var cashRegisterId: UUID? = nil   // admin sets; cashier omits (uses bound register)
    var cashierName: String? = nil
    var shiftPeriod: String? = nil    // morning | afternoon | full_day
    var shiftNumber: Int? = nil
    var openingBase: Decimal? = nil
}

struct ShiftCloseRequest: Encodable {
    var netSales: Decimal = 0
    var deliveries: Decimal = 0
    var creditInvoices: Decimal = 0
    var closingBase: Decimal? = nil
    var paymentMethods: [PaymentMethodIn] = []
    var denominations: [DenominationIn] = []
}

struct PaymentMethodDTO: Decodable {
    let method: String
    let amount: Decimal?
}

struct DenominationDTO: Decodable {
    let denomination: Int
    let quantity: Int
    let subtotal: Decimal?
}

struct ShiftDTO: Decodable, Identifiable {
    let id: UUID
    let cashRegisterId: UUID
    let cashierName: String?
    let shiftPeriod: String?
    let shiftNumber: Int?
    let openingBase: Decimal?
    let netSales: Decimal?
    let deliveries: Decimal?
    let creditInvoices: Decimal?
    let countedCash: Decimal?
    let expectedCash: Decimal?
    let closingBase: Decimal?
    let difference: Decimal?
    let status: String
    let openedAt: Date?
    let closedAt: Date?
    let paymentMethods: [PaymentMethodDTO]
    let denominations: [DenominationDTO]
}
