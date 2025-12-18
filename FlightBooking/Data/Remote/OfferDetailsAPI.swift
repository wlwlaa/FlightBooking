//
//  OfferDetailsAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 15.12.2025.
//


import Foundation

final class OfferDetailsAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func getDetails(offerId: String) async throws -> OfferDetailsResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/offers/\(offerId)"))
        req.httpMethod = "GET"
        return try await client.send(req)
    }

    func priceCheck(offerId: String) async throws -> PriceCheckResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/offers/\(offerId)/price-check"))
        req.httpMethod = "POST"
        return try await client.send(req)
    }
}
