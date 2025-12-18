//
//  LocationsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

protocol LocationsRepository {
    func autocomplete(query: String, limit: Int) async throws -> [LocationSuggestion]
}