//
//  DefaultFlightSearchRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

final class DefaultFlightSearchRepository: FlightSearchRepository {
    private let api: FlightSearchAPI

    init(api: FlightSearchAPI) { self.api = api }

    func search(_ query: SearchQuery) async throws -> [FlightOffer] {
        try await api.search(query)
    }
}
