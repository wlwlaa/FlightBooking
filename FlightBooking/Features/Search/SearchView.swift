//
//  SearchView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import SwiftUI

struct SearchView: View {
    @State var vm: SearchViewModel

    var body: some View {
        Form {
            Section("Route") {
                TextField("From (IATA)", text: $vm.fromIATA)
                    .textInputAutocapitalization(.characters)
                TextField("To (IATA)", text: $vm.toIATA)
                    .textInputAutocapitalization(.characters)
            }

            Section("Dates") {
                DatePicker("Depart", selection: $vm.departDate, displayedComponents: .date)
                Toggle("Return", isOn: $vm.returnEnabled)
                if vm.returnEnabled {
                    DatePicker("Return", selection: $vm.returnDate, displayedComponents: .date)
                }
            }

            Section("Passengers") {
                Stepper("Adults: \(vm.adults)", value: $vm.adults, in: 1...9)
                Picker("Cabin", selection: $vm.cabin) {
                    ForEach(CabinClass.allCases, id: \.self) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
            }

            Section {
                Button("Search") { vm.submit() }
                    .disabled(vm.fromIATA.count < 3 || vm.toIATA.count < 3)

//                Button("Preview (mock)") {
//                    Task { await vm.quickSearchPreview() }
//                }
//                .disabled(vm.fromIATA.count < 3 || vm.toIATA.count < 3)
            }

//            Section("Preview") {
//                switch vm.state {
//                case .idle:
//                    Text("No data")
//                case .loading:
//                    ProgressView()
//                case .failed(let msg):
//                    Text(msg)
//                case .loaded(let offers):
//                    ForEach(offers) { offer in
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("\(offer.fromIATA) → \(offer.toIATA)")
//                            Text("\(offer.carrier) • \(offer.price.amount) \(offer.price.currency)")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                }
//            }
        }
        .navigationTitle("Flights")
    }
}
