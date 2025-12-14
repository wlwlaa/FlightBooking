//
//  TripsView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import SwiftUI
import SwiftData

enum TripsSort: String, CaseIterable, Hashable {
    case newest = "Newest"
    case oldest = "Oldest"
}

struct TripsView: View {
    @Environment(\.modelContext) private var ctx

    @Query(sort: [SortDescriptor(\BookingRecord.createdAt, order: .reverse)])
    private var rows: [BookingRecord]

    @State private var statusFilter: BookingStatus? = nil
    @State private var sort: TripsSort = .newest

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                if filteredRows.isEmpty {
                    ContentUnavailableView(
                        "No trips yet",
                        systemImage: "airplane",
                        description: Text("Create a booking and it will appear here automatically.")
                    )
                } else {
                    List {
                        ForEach(filteredRows) { row in
                            TripRow(row: row)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("My Trips")
        }
    }

    private var header: some View {
        HStack {
            Picker("Status", selection: Binding(
                get: { statusFilter ?? .draft },
                set: { newValue in
                    // маленький хак: если пользователь выбирает Draft второй раз — сбрасываем фильтр
                    if statusFilter == newValue { statusFilter = nil }
                    else { statusFilter = newValue }
                }
            )) {
                Text("All").tag(BookingStatus.draft) // визуально "All", логика через nil
                ForEach(BookingStatus.allCases, id: \.self) { s in
                    Text(s.rawValue.capitalized).tag(s)
                }
            }
            .pickerStyle(.menu)

            Spacer()

            Picker("Sort", selection: $sort) {
                ForEach(TripsSort.allCases, id: \.self) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.thinMaterial)
    }

    private var filteredRows: [BookingRecord] {
        let base: [BookingRecord]
        if let f = statusFilter {
            base = rows.filter { $0.statusRaw == f.rawValue }
        } else {
            base = rows
        }

        switch sort {
        case .newest:
            return base.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return base.sorted { $0.createdAt < $1.createdAt }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            ctx.delete(filteredRows[i])
        }
        try? ctx.save()
    }
}

private struct TripRow: View {
    let row: BookingRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(row.fromIATA) → \(row.toIATA)")
                    .font(.headline)
                Spacer()
                Text(priceText)
                    .font(.headline)
            }

            HStack(spacing: 10) {
                Text(row.carrier).foregroundStyle(.secondary)
                Text(row.statusRaw.capitalized).foregroundStyle(.secondary)
                Text(timeRange).foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 6)
    }

    private var timeRange: String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .short
        return "\(f.string(from: row.departAt)) → \(f.string(from: row.arriveAt))"
    }

    private var priceText: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = row.priceCurrency
        let n = NSDecimalNumber(decimal: row.priceAmount)
        return f.string(from: n) ?? "\(row.priceAmount) \(row.priceCurrency)"
    }
}
