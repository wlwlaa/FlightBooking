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
            guard let booking = try await repo.get(id: bookingId) else {
                state = .failed("Booking not found")
                return
            }
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
            try await cancelBooking.execute(id: bookingId)
            await load()
            router.pop() // назад в список, он обновится сам через @Query
        } catch {
            errorMessage = error.localizedDescription
        }
        isCancelling = false
    }
}
