//
//  ConfirmBookingUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct ConfirmBookingUseCase {
    let repo: BookingRepository

    func execute(id: UUID) async throws -> Booking {
        try await repo.confirm(id: id)
    }
}