//
//  TripDetailsView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//
import SwiftUI

struct TripDetailsView: View {
    @State var vm: TripDetailsViewModel
    @State private var showCancelConfirm = false

    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let msg):
                ContentUnavailableView("Trip not available", systemImage: "xmark.circle", description: Text(msg))

            case .loaded(let booking):
                Form {
                    Section("Trip") {
                        HStack {
                            Text("\(booking.offer.fromIATA) → \(booking.offer.toIATA)")
                            Spacer()
                            Text(booking.offer.price.formatted()).font(.headline)
                        }
                        Text("\(booking.offer.carrier) • \(booking.status.rawValue.capitalized)")
                            .foregroundStyle(.secondary)
                    }

                    Section("Passengers") {
                        ForEach(booking.passengers) { p in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(p.firstName) \(p.lastName)")
                                Text(dateOnly(p.birthDate))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Doc: \(p.documentNumber)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if let err = vm.errorMessage {
                        Section { Text(err).foregroundStyle(.red) }
                    }

                    if booking.status != .canceled {
                        Section {
                            Button(role: .destructive) {
                                showCancelConfirm = true
                            } label: {
                                HStack {
                                    Spacer()
                                    if vm.isCancelling { ProgressView() } else { Text("Cancel booking") }
                                    Spacer()
                                }
                            }
                            .disabled(vm.isCancelling)
                        }
                    }
                }
            }
        }
        .navigationTitle("Trip Details")
        .task { await vm.load() }
        .alert("Cancel booking?", isPresented: $showCancelConfirm) {
            Button("Cancel booking", role: .destructive) { Task { await vm.cancel() } }
            Button("Keep", role: .cancel) {}
        }
    }

    private func dateOnly(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}
