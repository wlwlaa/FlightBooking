//
//  DefaultOfferDetailsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

final class DefaultOfferDetailsRepository: OfferDetailsRepository {
    func getDetails(for offer: FlightOffer) async throws -> OfferDetails {
        try await Task.sleep(nanoseconds: 200)

        return OfferDetails(
            offer: offer,
            fareName: "Standard",
            baggage: ["Personal item", "Cabin bag (8kg)"],
            rules: [
                "Changes allowed with fee",
                "Refund depends on fare conditions"
            ],
            refundable: false,
            changeFee: Money(amount: 35, currency: offer.price.currency)
        )
    }
}
