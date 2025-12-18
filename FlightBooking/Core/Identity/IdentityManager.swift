//
//  IdentityManager.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

actor IdentityManager {
    private let deviceIdProvider: DeviceIdProvider
    private let api: IdentityAPI
    private let defaults: UserDefaults

    private let tokenKey = "fb_guest_access_token"
    private let expKey = "fb_guest_expires_at"

    private var accessToken: String?
    private var expiresAt: Date?

    init(deviceIdProvider: DeviceIdProvider, api: IdentityAPI, defaults: UserDefaults = .standard) {
        self.deviceIdProvider = deviceIdProvider
        self.api = api
        self.defaults = defaults

        self.accessToken = defaults.string(forKey: tokenKey)
        if let t = defaults.object(forKey: expKey) as? Date { self.expiresAt = t }
    }

    func warmUpGuest() async {
        _ = try? await guestAccessToken()
    }

    func guestAccessToken() async throws -> String {
        if let token = accessToken, let exp = expiresAt, isValid(exp) {
            return token
        }

        let resp = try await api.guestAuth(deviceId: deviceIdProvider.deviceId)
        let exp = Date().addingTimeInterval(TimeInterval(resp.expiresIn))

        accessToken = resp.accessToken
        expiresAt = exp

        defaults.set(resp.accessToken, forKey: tokenKey)
        defaults.set(exp, forKey: expKey)

        return resp.accessToken
    }

    func validTokenIfAny() -> String? {
        guard let token = accessToken, let exp = expiresAt, isValid(exp) else { return nil }
        return token
    }

    func fetchMe() async throws -> MeResponseDTO {
        let token = try await guestAccessToken()
        return try await api.me(accessToken: token)
    }

    private func isValid(_ exp: Date) -> Bool {
        // refresh заранее, чтобы не ловить 401 на границе
        Date() < exp.addingTimeInterval(-60)
    }
}