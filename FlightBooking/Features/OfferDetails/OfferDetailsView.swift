//
//  OfferDetailsView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import SwiftUI

struct OfferDetailsView: View {
    @State var vm: OfferDetailsViewModel

    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let msg):
                ContentUnavailableView("Failed to load", systemImage: "xmark.circle", description: Text(msg))

            case .loaded(let details):
                if let t = vm.bannerText {
                    Section { Text(t).foregroundStyle(.secondary) }
                }
                if let e = vm.errorText {
                    Section { Text(e).foregroundStyle(.red) }
                }
                Form {
                    Section("Route") {
                        HStack {
                            Text("\(details.offer.fromIATA) → \(details.offer.toIATA)")
                            Spacer()
                            Text(details.offer.price.formatted())
                                .font(.headline)
                        }
                        Text(details.offer.carrier).foregroundStyle(.secondary)
                    }

                    if let fare = details.fareName {
                        Section("Fare") { Text(fare) }
                    }

                    Section("Baggage") {
                        ForEach(details.baggage, id: \.self) { Text($0) }
                    }

                    Section("Rules") {
                        ForEach(details.rules, id: \.self) { Text($0) }
                        if let refundable = details.refundable {
                            Text(refundable ? "Refundable" : "Non-refundable")
                                .foregroundStyle(.secondary)
                        }
                        if let fee = details.changeFee {
                            Text("Change fee: \(fee.formatted())")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Button {
                            Task { await vm.verifyAndBook() }
                        } label: {
                            HStack {
                                Spacer()
                                if vm.isChecking { ProgressView() } else { Text("Book") }
                                Spacer()
                            }
                        }
                        .disabled(vm.isChecking)
                        .buttonStyle(.borderedProminent)
                    }
                    Section("Validity") {
                        Text("Valid until: \(format(details.validUntil))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Details")
        .task { await vm.load() }
    }
}

private func format(_ d: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f.string(from: d)
}
