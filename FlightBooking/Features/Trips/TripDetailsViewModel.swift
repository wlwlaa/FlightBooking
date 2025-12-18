//
//  TripDetailsViewModel.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

@MainActor
@Observable
final class TripDetailsViewModel {
    let bookingId: UUID

    var state: LoadState<Booking> = .idle
    var isCancelling = false
    var errorMessage: String?

    private let repo: BookingRepository
    private let cancelBooking: CancelBookingUseCase
    private unowned let router: AppRouter

    init(bookingId: UUID, repo: BookingRepository, cancelBooking: CancelBookingUseCase, router: AppRouter) {
        self.bookingId = bookingId
        self.repo = repo
        self.cancelBooking = cancelBooking
        self.router = router
    }

    func load() async {
        state = .loading
        do {
            let booking = try await repo.get(id: bookingId)
            state = .loaded(booking)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func cancel() async {
        guard case .loaded(let booking) = state, booking.status != .canceled else { return }
        isCancelling = true
        errorMessage = nil

        do {
            _ = try await cancelBooking.execute(id: bookingId)
            router.pop()
        } catch {
            errorMessage = error.localizedDescription
        }

        isCancelling = false
    }
}
