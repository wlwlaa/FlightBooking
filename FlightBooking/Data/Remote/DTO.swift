//
//  MoneyDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 15.12.2025.
//


import Foundation

struct MoneyDTO: Codable, Hashable {
    var amount: Decimal
    var currency: String
    func toDomain() -> Money { Money(amount: amount, currency: currency) }
}

struct FlightOfferDTO: Codable, Hashable, Identifiable {
    var id: String
    var fromIATA: String
    var toIATA: String
    var departAt: Date
    var arriveAt: Date
    var price: MoneyDTO
    var carrier: String

    func toDomain() -> FlightOffer {
        FlightOffer(
            id: id,
            fromIATA: fromIATA,
            toIATA: toIATA,
            departAt: departAt,
            arriveAt: arriveAt,
            price: price.toDomain(),
            carrier: carrier
        )
    }

    static func fromDomain(_ o: FlightOffer) -> FlightOfferDTO {
        .init(
            id: o.id,
            fromIATA: o.fromIATA,
            toIATA: o.toIATA,
            departAt: o.departAt,
            arriveAt: o.arriveAt,
            price: MoneyDTO(amount: o.price.amount, currency: o.price.currency),
            carrier: o.carrier
        )
    }
}

struct SearchResponseDTO: Codable, Hashable {
    var offers: [FlightOfferDTO]
    var nextCursor: String?
}

struct OfferDetailsDTO: Codable, Hashable {
    var fareName: String?
    var baggage: [String]
    var rules: [String]
    var refundable: Bool?
    var changeFee: MoneyDTO?
}
