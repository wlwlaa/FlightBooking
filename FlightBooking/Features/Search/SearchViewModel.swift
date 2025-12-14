//
//  SearchViewModel.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var fromIATA: String = ""
    var toIATA: String = ""
    var departDate: Date = .now
    var returnEnabled: Bool = false
    var returnDate: Date = .now.addingTimeInterval(86400 * 7)
    var adults: Int = 1
    var cabin: CabinClass = .economy

    var state: LoadState<[FlightOffer]> = .idle

    private let searchFlights: SearchFlightsUseCase
    private unowned let router: AppRouter

    init(searchFlights: SearchFlightsUseCase, router: AppRouter) {
        self.searchFlights = searchFlights
        self.router = router
    }

    func submit() {
        let query = SearchQuery(
            fromIATA: fromIATA.uppercased(),
            toIATA: toIATA.uppercased(),
            departDate: departDate,
            returnDate: returnEnabled ? returnDate : nil,
            adults: max(1, adults),
            cabin: cabin
        )
        router.push(.results(query))
    }

    func quickSearchPreview() async {
        state = .loading
        do {
            let query = SearchQuery(
                fromIATA: fromIATA.uppercased(),
                toIATA: toIATA.uppercased(),
                departDate: departDate,
                returnDate: returnEnabled ? returnDate : nil,
                adults: max(1, adults),
                cabin: cabin
            )
            let offers = try await searchFlights.execute(query)
            state = .loaded(offers)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
