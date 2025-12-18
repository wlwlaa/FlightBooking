//
//  APIError 2.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

enum APIError: LocalizedError {
    case httpStatus(Int, ErrorResponse?)
    case decodeFailed(String)
    case badServerResponse

    var errorDescription: String? {
        switch self {
        case .httpStatus(let status, let err):
            if let err {
                return "HTTP \(status) • \(err.code): \(err.message) • traceId=\(err.traceId)"
            }
            return "HTTP \(status)"
        case .decodeFailed(let msg):
            return "Decode failed: \(msg)"
        case .badServerResponse:
            return "Bad server response"
        }
    }
}