//
//  CancelBookingUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct CancelBookingUseCase {
    let repo: BookingRepository

    func execute(id: UUID) async throws -> Booking {
        try await repo.cancel(id: id)
    }
}
