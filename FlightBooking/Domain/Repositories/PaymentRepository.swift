//
//  PaymentRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

protocol PaymentRepository {
    func createIntent(bookingId: UUID, amount: Double?, currency: String?) async throws -> PaymentIntent
}