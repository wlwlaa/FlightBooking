//
//  SearchQuery.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct SearchQuery: Codable, Hashable {
    var fromIATA: String
    var toIATA: String
    var departDate: Date
    var returnDate: Date?
    var adults: Int
    var cabin: CabinClass
}

enum CabinClass: String, Codable, CaseIterable, Hashable {
    case economy, premiumEconomy, business, first
}
