//
//  SwiftDataBookingRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@MainActor
final class SwiftDataBookingRepository: BookingRepository {
    private let stack: SwiftDataStack

    init(stack: SwiftDataStack) { self.stack = stack }

    func list() async throws -> [Booking] {
        let ctx = stack.makeContext()
        let desc = FetchDescriptor<BookingRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let rows = try ctx.fetch(desc)
        return rows.compactMap { $0.toDomain() }
    }

    func create(offer: FlightOffer, passengers: [Passenger]) async throws -> Booking {
        let ctx = stack.makeContext()

        let bookingId = UUID()
        let payload = try JSONEncoder().encode(offer)

        let record = BookingRecord(
            id: bookingId,
            createdAt: .now,
            statusRaw: BookingStatus.confirmed.rawValue,
            fromIATA: offer.fromIATA,
            toIATA: offer.toIATA,
            departAt: offer.departAt,
            arriveAt: offer.arriveAt,
            priceAmount: offer.price.amount,
            priceCurrency: offer.price.currency,
            carrier: offer.carrier,
            offerPayload: payload
        )

        record.passengers = passengers.map {
            PassengerRecord(
                id: $0.id,
                firstName: $0.firstName,
                lastName: $0.lastName,
                birthDate: $0.birthDate,
                documentNumber: $0.documentNumber
            )
        }
        record.passengers.forEach { $0.booking = record }

        ctx.insert(record)
        try ctx.save()

        return record.toDomain()!
    }

    func updateStatus(id: UUID, status: BookingStatus) async throws {
        let ctx = stack.makeContext()
        let desc = FetchDescriptor<BookingRecord>(predicate: #Predicate { $0.id == id })
        guard let row = try ctx.fetch(desc).first else { return }
        row.statusRaw = status.rawValue
        try ctx.save()
    }
    
    func get(id: UUID) async throws -> Booking? {
        let ctx = stack.makeContext()
        let desc = FetchDescriptor<BookingRecord>(predicate: #Predicate { $0.id == id })
        return try ctx.fetch(desc).first?.toDomain()
    }
}

private extension BookingRecord {
    func toDomain() -> Booking? {
        let status = BookingStatus(rawValue: statusRaw) ?? .draft

        let offer: FlightOffer
        if let offerPayload, let decoded = try? JSONDecoder.iso8601.decode(FlightOffer.self, from: offerPayload) {
            offer = decoded
        } else {
            offer = FlightOffer(
                id: id.uuidString,
                fromIATA: fromIATA,
                toIATA: toIATA,
                departAt: departAt,
                arriveAt: arriveAt,
                price: Money(amount: priceAmount, currency: priceCurrency),
                carrier: carrier
            )
        }

        let pax = passengers.map {
            Passenger(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, birthDate: $0.birthDate, documentNumber: $0.documentNumber)
        }

        return Booking(id: id, createdAt: createdAt, status: status, offer: offer, passengers: pax)
    }
}
