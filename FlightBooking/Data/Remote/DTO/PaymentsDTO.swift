//
//  PaymentsDTO.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//

import Foundation

struct CreatePaymentIntentRequestDTO: Codable, Hashable {
    let bookingId: UUID
    let amount: Double?
    let currency: String?
}

struct CreatePaymentIntentResponseDTO: Decodable, Hashable {
    let provider: String
    let clientSecret: String
}
