//
//  DefaultOfferDetailsRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

final class DefaultOfferDetailsRepository: OfferDetailsRepository {
    private let api: OfferDetailsAPI

    init(api: OfferDetailsAPI) { self.api = api }

    func getDetails(for offer: FlightOffer) async throws -> OfferDetails {
        let dto = try await api.getDetails(offerId: offer.id)
        return OfferDetails(
            offer: offer,
            fareName: dto.fareName,
            baggage: dto.baggage,
            rules: dto.rules,
            refundable: dto.refundable,
            changeFee: dto.changeFee?.toDomain()
        )
    }
}
