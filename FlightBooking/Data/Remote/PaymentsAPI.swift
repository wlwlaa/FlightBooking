//
//  PaymentsAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class PaymentsAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func createIntent(bookingId: UUID, amount: Double? = nil, currency: String? = nil) async throws -> CreatePaymentIntentResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/payments/intent"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.iso8601.encode(
            CreatePaymentIntentRequestDTO(bookingId: bookingId, amount: amount, currency: currency)
        )
        return try await client.send(req)
    }
}