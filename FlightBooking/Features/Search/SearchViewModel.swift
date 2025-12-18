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

    // ✅ Autocomplete state
    var fromSuggestions: [LocationSuggestion] = []
    var toSuggestions: [LocationSuggestion] = []
    var isLoadingFrom = false
    var isLoadingTo = false

    private var fromTask: Task<Void, Never>?
    private var toTask: Task<Void, Never>?

    private let searchFlights: SearchFlightsUseCase
    private let autocomplete: AutocompleteLocationsUseCase
    private unowned let router: AppRouter

    init(searchFlights: SearchFlightsUseCase, autocomplete: AutocompleteLocationsUseCase, router: AppRouter) {
        self.searchFlights = searchFlights
        self.autocomplete = autocomplete
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
            let page = try await searchFlights.execute(query)
            state = .loaded(page.offers)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Autocomplete handlers (debounced)
    func onFromChanged(_ text: String) {
        fromTask?.cancel()
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.count < 2 {
            fromSuggestions = []
            isLoadingFrom = false
            return
        }
        isLoadingFrom = true
        fromTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            do {
                let items = try await autocomplete.execute(query: q, limit: 8)
                if !Task.isCancelled { fromSuggestions = items }
            } catch {
                if !Task.isCancelled { fromSuggestions = [] }
            }
            if !Task.isCancelled { isLoadingFrom = false }
        }
    }

    func onToChanged(_ text: String) {
        toTask?.cancel()
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.count < 2 {
            toSuggestions = []
            isLoadingTo = false
            return
        }
        isLoadingTo = true
        toTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            do {
                let items = try await autocomplete.execute(query: q, limit: 8)
                if !Task.isCancelled { toSuggestions = items }
            } catch {
                if !Task.isCancelled { toSuggestions = [] }
            }
            if !Task.isCancelled { isLoadingTo = false }
        }
    }

    func selectFrom(_ item: LocationSuggestion) {
        fromIATA = item.iata.uppercased()
        fromSuggestions = []
    }

    func selectTo(_ item: LocationSuggestion) {
        toIATA = item.iata.uppercased()
        toSuggestions = []
    }
}
