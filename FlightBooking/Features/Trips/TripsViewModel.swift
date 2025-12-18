//
//  TripsViewModel.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

@MainActor
@Observable
final class TripsViewModel {
    var items: [BookingSummary] = []
    var nextCursor: String? = nil
    var isLoading = false
    var isLoadingMore = false
    var error: String?

    var status: BookingStatus? = nil

    private let repo: BookingRepository

    init(repo: BookingRepository) { self.repo = repo }

    func load() async {
        isLoading = true
        error = nil
        do {
            let page = try await repo.listPage(status: status, from: nil, to: nil, cursor: nil, limit: 20)
            items = page.items
            nextCursor = page.nextCursor
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard let cursor = nextCursor, !isLoadingMore else { return }
        isLoadingMore = true
        do {
            let page = try await repo.listPage(status: status, from: nil, to: nil, cursor: cursor, limit: 20)
            items.append(contentsOf: page.items)
            nextCursor = page.nextCursor
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingMore = false
    }
}
