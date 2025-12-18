//
//  RemotePaymentRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class RemotePaymentRepository: PaymentRepository {
    private let api: PaymentsAPI

    init(api: PaymentsAPI) { self.api = api }

    func createIntent(bookingId: UUID, amount: Double?, currency: String?) async throws -> PaymentIntent {
        let dto = try await api.createIntent(bookingId: bookingId, amount: amount, currency: currency)
        return PaymentIntent(provider: dto.provider, clientSecret: dto.clientSecret)
    }
}