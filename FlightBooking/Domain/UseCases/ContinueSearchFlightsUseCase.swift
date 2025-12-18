//
//  ContinueSearchFlightsUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct ContinueSearchFlightsUseCase {
    let repo: FlightSearchRepository

    func execute(cursor: String, limit: Int? = nil) async throws -> FlightSearchPage {
        try await repo.continueSearch(cursor: cursor, limit: limit)
    }
}