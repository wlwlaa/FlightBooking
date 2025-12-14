//
//  OfferDetails.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct OfferDetails: Codable, Hashable {
    var offer: FlightOffer
    var fareName: String?
    var baggage: [String]
    var rules: [String]
    var refundable: Bool?
    var changeFee: Money?
}
