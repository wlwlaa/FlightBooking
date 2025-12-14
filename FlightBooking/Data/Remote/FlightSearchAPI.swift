//
//  FlightSearchAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

final class FlightSearchAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func search(_ query: SearchQuery) async throws -> [FlightOffer] {
        var req = URLRequest(url: baseURL.appendingPathComponent("/v1/flights/search"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.iso8601.encode(query)

        let dto: SearchResponseDTO = try await client.send(req)
        return dto.offers.map { $0.toDomain() }
    }
}
