//
//  CreatePaymentIntentUseCase.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct CreatePaymentIntentUseCase {
    let repo: PaymentRepository

    func execute(bookingId: UUID, amount: Double? = nil, currency: String? = nil) async throws -> PaymentIntent {
        try await repo.createIntent(bookingId: bookingId, amount: amount, currency: currency)
    }
}