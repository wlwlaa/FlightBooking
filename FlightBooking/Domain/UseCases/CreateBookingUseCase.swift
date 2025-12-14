//
//  CreateBookingUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct CreateBookingUseCase {
    let repo: BookingRepository

    func execute(offer: FlightOffer, passengers: [Passenger]) async throws -> Booking {
        try await repo.create(offer: offer, passengers: passengers)
    }
}
