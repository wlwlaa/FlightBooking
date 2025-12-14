//
//  ResultsSort.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

enum ResultsSort: String, CaseIterable, Hashable {
    case best = "Best"
    case cheapest = "Cheapest"
    case earliest = "Earliest"
    case shortest = "Shortest"
}

@MainActor
@Observable
final class ResultsViewModel {
    let query: SearchQuery

    var offers: [FlightOffer] = []
    var isLoading = true
    var isRefreshing = false
    var errorMessage: String?
    var sourceLabel: String? = nil

    var sort: ResultsSort = .best {
        didSet { applySort() }
    }

    private let searchFlights: SearchFlightsUseCase
    private let cache: OfferCacheRepository
    private unowned let router: AppRouter

    private let cacheMaxAge: TimeInterval = 15 * 60

    init(query: SearchQuery, searchFlights: SearchFlightsUseCase, cache: OfferCacheRepository, router: AppRouter) {
        self.query = query
        self.searchFlights = searchFlights
        self.cache = cache
        self.router = router
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        sourceLabel = nil

        // 1) cache
        if let cached = try? await cache.getCachedOffers(for: query, maxAge: cacheMaxAge), !cached.isEmpty {
            offers = cached
            applySort()
            sourceLabel = "cached"
            isLoading = false
            isRefreshing = true
        }

        // 2) remote
        do {
            let fresh = try await searchFlights.execute(query)
            offers = fresh
            applySort()
            sourceLabel = "live"
            isLoading = false
            isRefreshing = false
            try? await cache.saveCachedOffers(fresh, for: query)
        } catch {
            isLoading = false
            isRefreshing = false
            if offers.isEmpty { errorMessage = error.localizedDescription }
        }
    }

    func refresh() async {
        isRefreshing = true
        do {
            let fresh = try await searchFlights.execute(query)
            offers = fresh
            applySort()
            sourceLabel = "live"
            isRefreshing = false
            try? await cache.saveCachedOffers(fresh, for: query)
        } catch {
            isRefreshing = false
            errorMessage = error.localizedDescription
        }
    }

    func openDetails(_ offer: FlightOffer) { router.push(.offerDetails(offer)) }
    func book(_ offer: FlightOffer) { router.push(.booking(offer)) }

    private func applySort() {
        switch sort {
        case .best:
            break
        case .cheapest:
            offers.sort { $0.price.amount < $1.price.amount }
        case .earliest:
            offers.sort { $0.departAt < $1.departAt }
        case .shortest:
            offers.sort { ($0.arriveAt.timeIntervalSince($0.departAt)) < ($1.arriveAt.timeIntervalSince($1.departAt)) }
        }
    }
}
