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
    let offer: FlightOffer

    var state: LoadState<OfferDetails> = .idle

    private let getDetails: GetOfferDetailsUseCase
    private unowned let router: AppRouter

    init(offer: FlightOffer, getDetails: GetOfferDetailsUseCase, router: AppRouter) {
        self.offer = offer
        self.getDetails = getDetails
        self.router = router
    }

    func load() async {
        state = .loading
        do {
            let details = try await getDetails.execute(offer: offer)
            state = .loaded(details)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func bookNow() {
        router.push(.booking(offer))
    }
}
