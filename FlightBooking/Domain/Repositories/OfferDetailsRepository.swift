//
//  OfferDetailsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol OfferDetailsRepository {
    func getDetails(for offer: FlightOffer) async throws -> OfferDetails
    func priceCheck(offerId: String) async throws -> PriceCheckResult
}
