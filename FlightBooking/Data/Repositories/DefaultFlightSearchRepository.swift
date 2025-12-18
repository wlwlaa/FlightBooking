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

    func search(_ query: SearchQuery) async throws -> FlightSearchPage {
        let dto = try await api.search(query)
        return FlightSearchPage(
            offers: dto.offers.map { $0.toDomain() },
            nextCursor: dto.nextCursor
        )
    }

    func continueSearch(cursor: String, limit: Int?) async throws -> FlightSearchPage {
        let dto = try await api.continueSearch(cursor: cursor, limit: limit)
        return FlightSearchPage(
            offers: dto.offers.map { $0.toDomain() },
            nextCursor: dto.nextCursor
        )
    }
}
