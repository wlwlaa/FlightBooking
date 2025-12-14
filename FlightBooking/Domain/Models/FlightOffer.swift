//
//  FlightOffer.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct FlightOffer: Identifiable, Codable, Hashable {
    var id: String
    var fromIATA: String
    var toIATA: String
    var departAt: Date
    var arriveAt: Date
    var price: Money
    var carrier: String
}

struct Money: Codable, Hashable {
    var amount: Decimal
    var currency: String
}
