//
//  BookingsDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//

import Foundation

struct ContactDTO: Codable, Hashable {
    let email: String
    let phone: String?

    func toDomain() -> Contact { .init(email: email, phone: phone) }
    static func fromDomain(_ c: Contact) -> ContactDTO { .init(email: c.email, phone: c.phone) }
}

struct PassengerDTO: Codable, Hashable {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let documentNumber: String

    func toDomain() -> Passenger {
        Passenger(firstName: firstName, lastName: lastName, birthDate: birthDate, documentNumber: documentNumber)
    }

    static func fromDomain(_ p: Passenger) -> PassengerDTO {
        .init(firstName: p.firstName, lastName: p.lastName, birthDate: p.birthDate, documentNumber: p.documentNumber)
    }
}

struct CreateBookingRequestDTO: Codable, Hashable {
    let offerId: String
    let contact: ContactDTO
    let passengers: [PassengerDTO]
}

struct BookingResponseDTO: Decodable, Hashable {
    let id: UUID
    let createdAt: Date
    let status: BookingStatus
    let offer: FlightOfferSummaryDTO
    let contact: ContactDTO
    let passengers: [PassengerDTO]
}

struct BookingSummaryDTO: Decodable, Hashable {
    let id: UUID
    let createdAt: Date
    let status: BookingStatus
    let offer: FlightOfferSummaryDTO
}

struct BookingListResponseDTO: Decodable, Hashable {
    let items: [BookingSummaryDTO]
    let nextCursor: String?
}
