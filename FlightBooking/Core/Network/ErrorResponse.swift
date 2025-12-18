//
//  ErrorResponse.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

struct ErrorResponse: Decodable, Hashable {
    let code: String
    let message: String
    let traceId: String
    let details: [String: JSONValue]?
}