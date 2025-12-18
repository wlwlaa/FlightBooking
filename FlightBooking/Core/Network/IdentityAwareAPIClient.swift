//
//  IdentityAwareAPIClient.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class IdentityAwareAPIClient: APIClientProtocol {
    private let base: APIClientProtocol
    private let deviceIdProvider: DeviceIdProvider
    private let identity: IdentityManager
    private let shouldAttachIdentity: (URLRequest) -> Bool
    private let shouldAttachDeviceId: (URLRequest) -> Bool
    private let shouldAttachIdempotency: (URLRequest) -> Bool

    init(
        base: APIClientProtocol,
        deviceIdProvider: DeviceIdProvider,
        identity: IdentityManager,
        shouldAttachIdentity: @escaping (URLRequest) -> Bool,
        shouldAttachDeviceId: @escaping (URLRequest) -> Bool,
        shouldAttachIdempotency: @escaping (URLRequest) -> Bool
    ) {
        self.base = base
        self.deviceIdProvider = deviceIdProvider
        self.identity = identity
        self.shouldAttachIdentity = shouldAttachIdentity
        self.shouldAttachDeviceId = shouldAttachDeviceId
        self.shouldAttachIdempotency = shouldAttachIdempotency
    }

    private func prepared(_ request: URLRequest) async throws -> URLRequest {
        var req = request

        if shouldAttachDeviceId(req), req.value(forHTTPHeaderField: "X-Device-Id") == nil {
            req.setValue(deviceIdProvider.deviceId, forHTTPHeaderField: "X-Device-Id")
        }

        if shouldAttachIdempotency(req), req.value(forHTTPHeaderField: "Idempotency-Key") == nil {
            req.setValue(UUID().uuidString.lowercased(), forHTTPHeaderField: "Idempotency-Key")
        }

        if shouldAttachIdentity(req), req.value(forHTTPHeaderField: "Authorization") == nil {
            // если guest auth сломается — всё равно можно жить на X-Device-Id
            do {
                let token = try await identity.guestAccessToken()
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } catch { }
        }

        return req
    }

    func sendRaw(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let req = try await prepared(request)
        return try await base.sendRaw(req)
    }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await sendRaw(request)
        do {
            return try JSONDecoder.iso8601.decode(T.self, from: data)
        } catch {
            throw APIError.decodeFailed(error.localizedDescription)
        }
    }
}
