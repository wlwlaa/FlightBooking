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
                TextField("From (IATA / city)", text: $vm.fromIATA)
                    .textInputAutocapitalization(.characters)
                    .onChange(of: vm.fromIATA) { vm.onFromChanged($0) }

                if vm.isLoadingFrom { ProgressView().scaleEffect(0.8) }

                if !vm.fromSuggestions.isEmpty {
                    ForEach(vm.fromSuggestions) { s in
                        Button {
                            vm.selectFrom(s)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(s.iata) • \(s.name)")
                                Text("\((s.city ?? s.country))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                TextField("To (IATA / city)", text: $vm.toIATA)
                    .textInputAutocapitalization(.characters)
                    .onChange(of: vm.toIATA) { vm.onToChanged($0) }

                if vm.isLoadingTo { ProgressView().scaleEffect(0.8) }

                if !vm.toSuggestions.isEmpty {
                    ForEach(vm.toSuggestions) { s in
                        Button {
                            vm.selectTo(s)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(s.iata) • \(s.name)")
                                Text("\((s.city ?? s.country))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
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
            }
        }
        .navigationTitle("Flights")
    }
}
