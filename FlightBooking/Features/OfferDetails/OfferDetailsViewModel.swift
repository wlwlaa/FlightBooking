//
//  OfferDetailsViewModel.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

@MainActor
@Observable
final class OfferDetailsViewModel {
    var offer: FlightOffer
    var state: LoadState<OfferDetails> = .idle

    var isChecking = false
    var bannerText: String?
    var errorText: String?

    private let getDetails: GetOfferDetailsUseCase
    private let priceCheck: PriceCheckOfferUseCase
    private unowned let router: AppRouter

    init(
        offer: FlightOffer,
        getDetails: GetOfferDetailsUseCase,
        priceCheck: PriceCheckOfferUseCase,
        router: AppRouter
    ) {
        self.offer = offer
        self.getDetails = getDetails
        self.priceCheck = priceCheck
        self.router = router
    }

    func load() async {
        state = .loading
        errorText = nil
        do {
            let details = try await getDetails.execute(offer: offer)
            self.offer = details.offer
            state = .loaded(details)
        } catch {
            state = .failed(offerUserMessage(error))
        }
    }

    func verifyAndBook() async {
        isChecking = true
        bannerText = nil
        errorText = nil

        do {
            let result = try await priceCheck.execute(offerId: offer.id)

            // обновляем оффер (цена/validUntil могут поменяться)
            self.offer = result.offer

            if case .loaded(var details) = state {
                details.offer = result.offer
                details.validUntil = result.offer.validUntil
                state = .loaded(details)
            }

            if result.priceChanged {
                bannerText = "Price updated to \(result.offer.price.formatted())"
            }

            router.push(.booking(result.offer))
        } catch {
            errorText = offerUserMessage(error)
        }

        isChecking = false
    }
    
    private func offerUserMessage(_ error: Error) -> String {
        if let api = error as? APIError {
            switch api {
            case .httpStatus(let code, _) where code == 404 || code == 409:
                return "Offer expired"
            default:
                break
            }
        }
        return error.localizedDescription
    }
}

