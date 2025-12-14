//
//  SearchHistoryRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol SearchHistoryRepository {
    func save(_ query: SearchQuery) async throws
    func latest(limit: Int) async throws -> [SearchQuery]
}
