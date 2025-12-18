//
//  DefaultLocationsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class DefaultLocationsRepository: LocationsRepository {
    private let api: LocationsAPI

    init(api: LocationsAPI) { self.api = api }

    func autocomplete(query: String, limit: Int) async throws -> [LocationSuggestion] {
        let resp = try await api.autocomplete(query: query, limit: limit)
        return resp.items.map {
            LocationSuggestion(
                iata: $0.iata,
                type: $0.type,
                name: $0.name,
                country: $0.country,
                city: $0.city,
                lat: $0.lat,
                lon: $0.lon
            )
        }
    }
}