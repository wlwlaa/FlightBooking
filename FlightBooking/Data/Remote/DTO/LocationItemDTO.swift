//
//  LocationItemDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct LocationItemDTO: Decodable, Hashable {
    let iata: String
    let type: String
    let name: String
    let country: String
    let city: String?
    let lat: Double
    let lon: Double
}

struct LocationsAutocompleteResponseDTO: Decodable, Hashable {
    let items: [LocationItemDTO]
}

final class LocationsAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func autocomplete(query: String, limit: Int = 10) async throws -> LocationsAutocompleteResponseDTO {
        var comps = URLComponents(url: baseURL.appendingPathComponent("v1/locations/autocomplete"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "query", value: query),
            .init(name: "limit", value: String(limit))
        ]
        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        return try await client.send(req)
    }
}