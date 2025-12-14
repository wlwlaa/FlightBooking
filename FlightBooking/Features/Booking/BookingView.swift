//
//  BookingView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import SwiftUI

struct BookingView: View {
    @State var vm: BookingViewModel

    var body: some View {
        if let booking = vm.createdBooking {
            BookingConfirmationView(booking: booking, onDone: { vm.finish() })
                .navigationTitle("Confirmed")
        } else {
            Form {
                Section("Trip") {
                    HStack {
                        Text("\(vm.offer.fromIATA) → \(vm.offer.toIATA)")
                        Spacer()
                        Text(vm.offer.price.formatted()).font(.headline)
                    }
                    Text(vm.offer.carrier).foregroundStyle(.secondary)
                }

                Section("Passengers") {
                    ForEach($vm.passengers) { $p in
                        PassengerFormCard(p: $p, onRemove: { vm.removePassenger(id: p.id) })
                    }
                    Button("Add passenger") { vm.addPassenger() }
                }

                if let msg = vm.errorMessage {
                    Section {
                        Text(msg).foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await vm.submit() }
                    } label: {
                        HStack {
                            Spacer()
                            if vm.isSubmitting { ProgressView() } else { Text("Confirm booking") }
                            Spacer()
                        }
                    }
                    .disabled(!vm.canSubmit || vm.isSubmitting)
                }
            }
            .navigationTitle("Booking")
        }
    }
}

private struct PassengerFormCard: View {
    @Binding var p: PassengerForm
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Passenger")
                    .font(.headline)
                Spacer()
                Button("Remove", role: .destructive, action: onRemove)
            }

            TextField("First name", text: $p.firstName)
            TextField("Last name", text: $p.lastName)
            DatePicker("Birth date", selection: $p.birthDate, displayedComponents: .date)
            TextField("Document # (optional)", text: $p.documentNumber)
        }
        .padding(.vertical, 6)
    }
}
