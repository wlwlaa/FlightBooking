//
//  BookingConfirmationView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import SwiftUI

struct BookingConfirmationView: View {
    let booking: Booking
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))

            Text("Booking confirmed")
                .font(.title2)
                .bold()

            Text("\(booking.offer.fromIATA) → \(booking.offer.toIATA)")
                .foregroundStyle(.secondary)

            Text(booking.offer.price.formatted())
                .font(.headline)

            Button("Go to My Trips", action: onDone)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
