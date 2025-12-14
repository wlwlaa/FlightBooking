//
//  Booking.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

struct Booking: Identifiable, Codable, Hashable {
    var id: UUID
    var createdAt: Date
    var status: BookingStatus
    var offer: FlightOffer
    var passengers: [Passenger]
}

enum BookingStatus: String, Codable, CaseIterable, Hashable {
    case draft, confirmed, canceled
}

struct Passenger: Identifiable, Codable, Hashable {
    var id: UUID
    var firstName: String
    var lastName: String
    var birthDate: Date
    var documentNumber: String?
}
