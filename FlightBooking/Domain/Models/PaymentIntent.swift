//
//  PaymentIntent.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct PaymentIntent: Hashable {
    let provider: String
    let clientSecret: String
}