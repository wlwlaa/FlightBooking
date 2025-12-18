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
    var email: String = ""
    var phone: String = ""
    var isSubmitting: Bool = false
    var errorMessage: String?
    var createdBooking: Booking?
    var isPaying = false
    var paymentInfoText: String?

    private let createBooking: CreateBookingUseCase
    private unowned let router: AppRouter
    
    private let createPaymentIntent: CreatePaymentIntentUseCase
    private let confirmBooking: ConfirmBookingUseCase

    init(
        offer: FlightOffer,
        createBooking: CreateBookingUseCase,
        createPaymentIntent: CreatePaymentIntentUseCase,
        confirmBooking: ConfirmBookingUseCase,
        router: AppRouter
    ) {
        self.offer = offer
        self.createBooking = createBooking
        self.createPaymentIntent = createPaymentIntent
        self.confirmBooking = confirmBooking
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
        let emailOk = email.contains("@") && email.contains(".")
        let paxOk = passengers.allSatisfy {
            !$0.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
            !$0.lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
            !$0.documentNumber.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return emailOk && paxOk
    }

    func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil

        do {
            let contact = Contact(
                email: email.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces).isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces)
            )

            let pax: [Passenger] = passengers.map {
                Passenger(
                    firstName: $0.firstName.trimmingCharacters(in: .whitespaces),
                    lastName: $0.lastName.trimmingCharacters(in: .whitespaces),
                    birthDate: $0.birthDate,
                    documentNumber: $0.documentNumber.trimmingCharacters(in: .whitespaces)
                )
            }

            let booking = try await createBooking.execute(offer: offer, contact: contact, passengers: pax)
            createdBooking = booking
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    func finish() {
        router.goToTripsAndReset()
    }
    
    func payAndConfirm() async {
        guard let b = createdBooking, b.status == .draft else { return }
        isPaying = true
        errorMessage = nil
        paymentInfoText = nil

        do {
            let intent = try await createPaymentIntent.execute(
                bookingId: b.id,
                amount: nil,
                currency: nil
            )
            paymentInfoText = "\(intent.provider) • \(intent.clientSecret)"

            let confirmed = try await confirmBooking.execute(id: b.id)
            createdBooking = confirmed
        } catch {
            errorMessage = error.localizedDescription
        }

        isPaying = false
    }
}
