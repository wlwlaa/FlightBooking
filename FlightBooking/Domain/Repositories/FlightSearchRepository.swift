//
//  FlightSearchRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol FlightSearchRepository {
    func search(_ query: SearchQuery) async throws -> [FlightOffer]
}
