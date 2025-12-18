//
//  PriceCheckOfferUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct PriceCheckOfferUseCase {
    let repo: OfferDetailsRepository

    func execute(offerId: String) async throws -> PriceCheckResult {
        try await repo.priceCheck(offerId: offerId)
    }
}