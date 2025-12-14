//
//  GetOfferDetailsUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct GetOfferDetailsUseCase {
    let repo: OfferDetailsRepository

    func execute(offer: FlightOffer) async throws -> OfferDetails {
        try await repo.getDetails(for: offer)
    }
}
