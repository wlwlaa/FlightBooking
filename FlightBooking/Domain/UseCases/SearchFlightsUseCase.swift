//
//  SearchFlightsUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct SearchFlightsUseCase {
    let repo: FlightSearchRepository
    let history: SearchHistoryRepository

    func execute(_ query: SearchQuery) async throws -> [FlightOffer] {
        try await history.save(query)
        return try await repo.search(query)
    }
}
