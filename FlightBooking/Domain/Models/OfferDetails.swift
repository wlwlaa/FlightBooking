//
//  OfferDetails.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

struct OfferDetails: Codable, Hashable {
    var offer: FlightOffer
    var offerId: String
    var fareName: String?
    var baggage: [String]
    var rules: [String]
    var refundable: Bool?
    var changeFee: Money?
    var validUntil: Date
}

struct PriceCheckResult: Hashable {
    let offer: FlightOffer
    let priceChanged: Bool
}
