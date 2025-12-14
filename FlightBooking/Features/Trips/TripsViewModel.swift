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
    var state: LoadState<[Booking]> = .idle
    private let repo: BookingRepository

    init(repo: BookingRepository) { self.repo = repo }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await repo.list())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
