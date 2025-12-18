//
//  LocationSuggestion.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct LocationSuggestion: Identifiable, Hashable {
    var id: String { iata + ":" + (city ?? "") + ":" + name }
    let iata: String
    let type: String
    let name: String
    let country: String
    let city: String?
    let lat: Double
    let lon: Double
}