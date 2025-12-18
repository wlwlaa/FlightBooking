//
//  TripsView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import SwiftUI

struct TripsView: View {
    let router: AppRouter
    @State var vm: TripsViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            if vm.isLoading && vm.items.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let e = vm.error, vm.items.isEmpty {
                ContentUnavailableView("Failed", systemImage: "xmark.circle", description: Text(e))
            } else if vm.items.isEmpty {
                ContentUnavailableView("No trips yet", systemImage: "airplane")
            } else {
                List {
                    ForEach(vm.items) { b in
                        Button {
                            router.push(.tripDetails(b.id))
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(b.offer.fromIATA) → \(b.offer.toIATA)").font(.headline)
                                Text("\(b.status.rawValue.capitalized) • \(b.offer.price.formatted())")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }

                    if vm.nextCursor != nil {
                        HStack {
                            Spacer()
                            if vm.isLoadingMore { ProgressView() }
                            else { Button("Load more") { Task { await vm.loadMore() } } }
                            Spacer()
                        }
                    }
                }
                .refreshable { await vm.load() }
            }
        }
        .navigationTitle("My Trips")
        .onAppear { Task { await vm.load() } }
    }

    private var header: some View {
        HStack {
            Picker("Status", selection: Binding(
                get: { vm.status ?? .draft },
                set: { newValue in
                    vm.status = (vm.status == newValue) ? nil : newValue
                    Task { await vm.load() }
                }
            )) {
                Text("All").tag(BookingStatus.draft)
                ForEach(BookingStatus.allCases, id: \.self) { s in
                    Text(s.rawValue.capitalized).tag(s)
                }
            }
            .pickerStyle(.menu)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.thinMaterial)
    }
}
