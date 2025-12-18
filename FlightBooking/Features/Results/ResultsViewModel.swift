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

import Foundation
import Observation

@MainActor
@Observable
final class ResultsViewModel {
    let query: SearchQuery

    var offers: [FlightOffer] = []
    var isLoading = true
    var isRefreshing = false
    var isLoadingMore = false
    var errorMessage: String?
    var sourceLabel: String? = nil

    var nextCursor: String? = nil

    var sort: ResultsSort = .best { didSet { applySort() } }

    private let searchFlights: SearchFlightsUseCase
    private let continueSearch: ContinueSearchFlightsUseCase
    private let cache: OfferCacheRepository
    private unowned let router: AppRouter

    private let cacheMaxAge: TimeInterval = 15 * 60

    init(
        query: SearchQuery,
        searchFlights: SearchFlightsUseCase,
        continueSearch: ContinueSearchFlightsUseCase,
        cache: OfferCacheRepository,
        router: AppRouter
    ) {
        self.query = query
        self.searchFlights = searchFlights
        self.continueSearch = continueSearch
        self.cache = cache
        self.router = router
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        sourceLabel = nil
        nextCursor = nil

        // cache (только offers)
        if let cached = try? await cache.getCachedOffers(for: query, maxAge: cacheMaxAge), !cached.isEmpty {
            offers = cached
            applySort()
            sourceLabel = "cached"
            isLoading = false
            isRefreshing = true
        }

        // remote (page)
        do {
            let page = try await searchFlights.execute(query)
            offers = page.offers
            nextCursor = page.nextCursor
            applySort()
            sourceLabel = "live"
            isLoading = false
            isRefreshing = false
            try? await cache.saveCachedOffers(page.offers, for: query)
        } catch {
            isLoading = false
            isRefreshing = false
            if offers.isEmpty { errorMessage = error.localizedDescription }
        }
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        do {
            let page = try await searchFlights.execute(query)
            offers = page.offers
            nextCursor = page.nextCursor
            applySort()
            sourceLabel = "live"
            isRefreshing = false
            try? await cache.saveCachedOffers(page.offers, for: query)
        } catch {
            isRefreshing = false
            errorMessage = error.localizedDescription
        }
    }

    func loadMore(limit: Int = 20) async {
        guard !isLoadingMore, let cursor = nextCursor else { return }
        isLoadingMore = true
        errorMessage = nil
        do {
            let page = try await continueSearch.execute(cursor: cursor, limit: limit)
            offers.append(contentsOf: page.offers)
            nextCursor = page.nextCursor
            applySort()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingMore = false
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
