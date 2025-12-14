//
//  APIClientProtocol.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol APIClientProtocol {
    func send<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class URLSessionAPIClient: APIClientProtocol {
    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1

        guard (200..<300).contains(code) else {
            let msg = String(data: data, encoding: .utf8)
            throw APIError.httpStatus(code, msg)
        }

        do {
            return try JSONDecoder.iso8601.decode(T.self, from: data)
        } catch {
            throw APIError.decodeFailed(error.localizedDescription)
        }
    }
}
