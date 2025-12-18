//
//  BookingRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol BookingRepository {
    func listPage(
        status: BookingStatus?,
        from: Date?,
        to: Date?,
        cursor: String?,
        limit: Int?
    ) async throws -> BookingPage

    func get(id: UUID) async throws -> Booking

    func createDraft(
        offerId: String,
        contact: Contact,
        passengers: [Passenger]
    ) async throws -> Booking
    
    func confirm(id: UUID) async throws -> Booking
    
    func cancel(id: UUID) async throws -> Booking
}
