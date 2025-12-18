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

    func search(_ query: SearchQuery) async throws -> FlightSearchResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/flights/search"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.iso8601.encode(FlightSearchRequestDTO(domain: query))
        return try await client.send(req)
    }

    func continueSearch(cursor: String, limit: Int? = nil) async throws -> FlightSearchResponseDTO {
        var comps = URLComponents(url: baseURL.appendingPathComponent("v1/flights/search"), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = [ .init(name: "cursor", value: cursor) ]
        if let limit { items.append(.init(name: "limit", value: String(limit))) }
        comps.queryItems = items

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        return try await client.send(req)
    }
}
