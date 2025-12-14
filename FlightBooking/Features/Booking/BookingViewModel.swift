//
//  BookingViewModel.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation
import Observation

struct PassengerForm: Identifiable, Hashable {
    var id = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    var documentNumber: String = ""
}

@MainActor
@Observable
final class BookingViewModel {
    let offer: FlightOffer

    var passengers: [PassengerForm] = [PassengerForm()]
    var isSubmitting: Bool = false
    var errorMessage: String?
    var createdBooking: Booking?

    private let createBooking: CreateBookingUseCase
    private unowned let router: AppRouter

    init(offer: FlightOffer, createBooking: CreateBookingUseCase, router: AppRouter) {
        self.offer = offer
        self.createBooking = createBooking
        self.router = router
    }

    func addPassenger() {
        passengers.append(PassengerForm())
    }

    func removePassenger(id: UUID) {
        passengers.removeAll { $0.id == id }
        if passengers.isEmpty { passengers = [PassengerForm()] }
    }

    var canSubmit: Bool {
        passengers.allSatisfy { !$0.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
                               !$0.lastName.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil

        let pax: [Passenger] = passengers.map {
            Passenger(
                id: $0.id,
                firstName: $0.firstName.trimmingCharacters(in: .whitespaces),
                lastName: $0.lastName.trimmingCharacters(in: .whitespaces),
                birthDate: $0.birthDate,
                documentNumber: $0.documentNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0.documentNumber
            )
        }

        do {
            let booking = try await createBooking.execute(offer: offer, passengers: pax)
            createdBooking = booking
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    func finish() {
        router.goToTripsAndReset()
    }
}
