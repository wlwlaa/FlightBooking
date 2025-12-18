//
//  FlightsDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//

import Foundation

struct MoneyDTO: Codable, Hashable {
    let amount: Double
    let currency: String

    func toDomain() -> Money {
        Money(amount: Decimal(amount), currency: currency)
    }
}

enum CabinDTO: String, Codable, Hashable {
    case economy
    case premium_economy
    case business
    case first

    init(domain: CabinClass) {
        switch domain {
        case .economy: self = .economy
        case .premiumEconomy: self = .premium_economy
        case .business: self = .business
        case .first: self = .first
        }
    }
}

struct FlightSearchRequestDTO: Codable, Hashable {
    let fromIATA: String
    let toIATA: String
    let departDate: Date
    let returnDate: Date?
    let adults: Int
    let cabin: CabinDTO

    init(domain q: SearchQuery) {
        self.fromIATA = q.fromIATA.uppercased()
        self.toIATA = q.toIATA.uppercased()
        self.departDate = q.departDate
        self.returnDate = q.returnDate
        self.adults = q.adults
        self.cabin = CabinDTO(domain: q.cabin)
    }
}

struct FlightOfferSummaryDTO: Codable, Hashable, Identifiable {
    let id: String
    let fromIATA: String
    let toIATA: String
    let departAt: Date
    let arriveAt: Date
    let price: MoneyDTO
    let carrier: String
    let validUntil: Date?

    func toDomain() -> FlightOffer {
        FlightOffer(
            id: id,
            fromIATA: fromIATA,
            toIATA: toIATA,
            departAt: departAt,
            arriveAt: arriveAt,
            price: price.toDomain(),
            carrier: carrier,
            validUntil: validUntil ?? .distantFuture
        )
    }
}

struct FlightSearchResponseDTO: Codable, Hashable {
    let offers: [FlightOfferSummaryDTO]
    let nextCursor: String?
}
