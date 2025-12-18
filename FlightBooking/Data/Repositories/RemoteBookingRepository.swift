//
//  RemoteBookingRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class RemoteBookingRepository: BookingRepository {
    private let api: BookingsAPI

    init(api: BookingsAPI) {
        self.api = api
    }

    func createDraft(offerId: String, contact: Contact, passengers: [Passenger]) async throws -> Booking {
        let dto = try await api.createDraft(
            .init(
                offerId: offerId,
                contact: .fromDomain(contact),
                passengers: passengers.map(PassengerDTO.fromDomain)
            )
        )
        return Booking(
            id: dto.id,
            createdAt: dto.createdAt,
            status: dto.status,
            offer: dto.offer.toDomain(),
            contact: dto.contact.toDomain(),
            passengers: dto.passengers.map { $0.toDomain() }
        )
    }

    func listPage(status: BookingStatus?, from: Date?, to: Date?, cursor: String?, limit: Int?) async throws -> BookingPage {
        let dto = try await api.list(status: status, from: from, to: to, cursor: cursor, limit: limit)
        return BookingPage(
            items: dto.items.map {
                BookingSummary(
                    id: $0.id,
                    createdAt: $0.createdAt,
                    status: $0.status,
                    offer: $0.offer.toDomain()
                )
            },
            nextCursor: dto.nextCursor
        )
    }

    func get(id: UUID) async throws -> Booking {
        let dto = try await api.get(id: id)
        return Booking(
            id: dto.id,
            createdAt: dto.createdAt,
            status: dto.status,
            offer: dto.offer.toDomain(),
            contact: dto.contact.toDomain(),
            passengers: dto.passengers.map { $0.toDomain() }
        )
    }
    
    func confirm(id: UUID) async throws -> Booking {
        let dto = try await api.confirm(id: id)
        return Booking(
            id: dto.id,
            createdAt: dto.createdAt,
            status: dto.status,
            offer: dto.offer.toDomain(),
            contact: dto.contact.toDomain(),
            passengers: dto.passengers.map { $0.toDomain() }
        )
    }
    
    func cancel(id: UUID) async throws -> Booking {
        let dto = try await api.cancel(id: id)
        return Booking(
            id: dto.id,
            createdAt: dto.createdAt,
            status: dto.status,
            offer: dto.offer.toDomain(),
            contact: dto.contact.toDomain(),
            passengers: dto.passengers.map { $0.toDomain() }
        )
    }
}
