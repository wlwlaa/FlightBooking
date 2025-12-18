//
//  OfferDetailsResponseDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct OfferDetailsResponseDTO: Decodable, Hashable {
    let offerId: String
    let fareName: String
    let baggage: [String]
    let rules: [String]
    let refundable: Bool
    let changeFee: MoneyDTO?
    let validUntil: Date
}

struct PriceCheckResponseDTO: Decodable, Hashable {
    let offer: FlightOfferSummaryDTO
    let priceChanged: Bool
}

struct OfferDetailsDTO: Codable, Hashable {
    var fareName: String?
    var baggage: [String]
    var rules: [String]
    var refundable: Bool?
    var changeFee: MoneyDTO?
}
