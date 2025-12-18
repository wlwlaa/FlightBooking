//
//  IdentityAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//

import Foundation

struct GuestAuthRequestDTO: Encodable {
    let deviceId: String
}

struct GuestAuthResponseDTO: Decodable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
}

struct MeUserResponseDTO: Decodable {
    let mode: String
    let id: String
    let email: String?
    let createdAt: Date?
}

struct MeGuestResponseDTO: Decodable {
    let mode: String
    let id: String
    let expiresAt: Date?
    let email: String?
    let createdAt: Date?
}

enum MeResponseDTO: Decodable {
    case user(MeUserResponseDTO)
    case guest(MeGuestResponseDTO)

    private enum CodingKeys: String, CodingKey { case mode }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let mode = try c.decode(String.self, forKey: .mode)
        switch mode {
        case "user":
            self = .user(try MeUserResponseDTO(from: decoder))
        case "guest":
            self = .guest(try MeGuestResponseDTO(from: decoder))
        default:
            self = .guest(try MeGuestResponseDTO(from: decoder))
        }
    }
}

final class IdentityAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func guestAuth(deviceId: String) async throws -> GuestAuthResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/auth/guest"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.iso8601.encode(GuestAuthRequestDTO(deviceId: deviceId))
        return try await client.send(req)
    }

    func me(accessToken: String) async throws -> MeResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return try await client.send(req)
    }
}
