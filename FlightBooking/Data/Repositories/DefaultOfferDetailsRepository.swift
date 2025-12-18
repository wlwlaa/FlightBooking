//
//  DefaultOfferDetailsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

final class DefaultOfferDetailsRepository: OfferDetailsRepository {
    private let api: OfferDetailsAPI

    init(api: OfferDetailsAPI) {
        self.api = api
    }

    func getDetails(for offer: FlightOffer) async throws -> OfferDetails {
        let dto = try await api.getDetails(offerId: offer.id)

        // details.validUntil — источник истины по истечению
        var updatedOffer = offer
        updatedOffer.validUntil = dto.validUntil

        return OfferDetails(
            offer: updatedOffer,
            offerId: dto.offerId,
            fareName: dto.fareName,
            baggage: dto.baggage,
            rules: dto.rules,
            refundable: dto.refundable,
            changeFee: dto.changeFee?.toDomain(),
            validUntil: dto.validUntil
        )
    }

    func priceCheck(offerId: String) async throws -> PriceCheckResult {
        let dto = try await api.priceCheck(offerId: offerId)
        return PriceCheckResult(
            offer: dto.offer.toDomain(),
            priceChanged: dto.priceChanged
        )
    }
}
