//
//  Booking.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

struct Contact: Codable, Hashable {
    var email: String
    var phone: String?
}

struct Passenger: Identifiable, Codable, Hashable {
    var id: UUID = UUID()          // локальный id для UI
    var firstName: String
    var lastName: String
    var birthDate: Date
    var documentNumber: String     // ✅ required по swagger
}

enum BookingStatus: String, Codable, CaseIterable, Hashable {
    case draft, confirmed, canceled
}

struct Booking: Identifiable, Codable, Hashable {
    var id: UUID
    var createdAt: Date
    var status: BookingStatus
    var offer: FlightOffer
    var contact: Contact
    var passengers: [Passenger]
}

struct BookingSummary: Identifiable, Hashable {
    var id: UUID
    var createdAt: Date
    var status: BookingStatus
    var offer: FlightOffer
}

struct BookingPage: Hashable {
    var items: [BookingSummary]
    var nextCursor: String?
}
