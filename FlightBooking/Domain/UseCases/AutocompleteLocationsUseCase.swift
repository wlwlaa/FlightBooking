//
//  AutocompleteLocationsUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct AutocompleteLocationsUseCase {
    let repo: LocationsRepository

    func execute(query: String, limit: Int = 10) async throws -> [LocationSuggestion] {
        try await repo.autocomplete(query: query, limit: limit)
    }
}