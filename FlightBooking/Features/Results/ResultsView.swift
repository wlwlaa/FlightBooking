//
//  ResultsView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import SwiftUI

struct ResultsView: View {
    @State var vm: ResultsViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            if vm.isLoading && vm.offers.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let msg = vm.errorMessage, vm.offers.isEmpty {
                ContentUnavailableView("No results", systemImage: "xmark.circle", description: Text(msg))
            } else {
                List {
                    ForEach(vm.offers) { offer in
                        OfferRow(
                            offer: offer,
                            onDetails: { vm.openDetails(offer) },
                            onBook: { vm.book(offer) }
                        )
                    }
                }
                .refreshable { await vm.refresh() }
            }
        }
        .navigationTitle("Results")
        .task { await vm.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(vm.query.fromIATA.uppercased()) → \(vm.query.toIATA.uppercased())")
                    .font(.headline)
                Spacer()
                if vm.isRefreshing { ProgressView().scaleEffect(0.8) }
            }

            HStack {
                Picker("Sort", selection: $vm.sort) {
                    ForEach(ResultsSort.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.menu)

                Spacer()

                if let source = vm.sourceLabel {
                    Text(source).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }
}

private struct OfferRow: View {
    let offer: FlightOffer
    let onDetails: () -> Void
    let onBook: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(offer.fromIATA) → \(offer.toIATA)")
                    .font(.headline)
                Spacer()
                Text(offer.price.formatted())
                    .font(.headline)
            }

            HStack(spacing: 10) {
                Text(offer.carrier).foregroundStyle(.secondary)
                Text(timeRange).foregroundStyle(.secondary)
                Text(durationText).foregroundStyle(.secondary)
            }
            .font(.subheadline)

            HStack {
                Button("Details", action: onDetails)
                Spacer()
                Button("Book", action: onBook)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 6)
    }

    private var timeRange: String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.timeStyle = .short
        f.dateStyle = .none
        return "\(f.string(from: offer.departAt)) – \(f.string(from: offer.arriveAt))"
    }

    private var durationText: String {
        let mins = Int(offer.arriveAt.timeIntervalSince(offer.departAt) / 60)
        return "\(mins / 60)h \(mins % 60)m"
    }
}

