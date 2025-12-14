//
//  BookingRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol BookingRepository {
    func list() async throws -> [Booking]
    func get(id: UUID) async throws -> Booking?
    func create(offer: FlightOffer, passengers: [Passenger]) async throws -> Booking
    func updateStatus(id: UUID, status: BookingStatus) async throws
}
