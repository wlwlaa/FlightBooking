//
//  FlightSearchPage.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct FlightSearchPage: Hashable {
    let offers: [FlightOffer]
    let nextCursor: String?
}