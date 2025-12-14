//
//  FlightSearchAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

final class FlightSearchAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func search(_ query: SearchQuery) async throws -> [FlightOffer] {
        // Заглушка: здесь соберёшь реальный endpoint
        // Сейчас возвращаем mock, чтобы UI работал.
        try await Task.sleep(nanoseconds: 250_000_000)

        return [
            FlightOffer(
                id: UUID().uuidString,
                fromIATA: query.fromIATA,
                toIATA: query.toIATA,
                departAt: query.departDate.addingTimeInterval(3600 * 9),
                arriveAt: query.departDate.addingTimeInterval(3600 * 13),
                price: Money(amount: 199.99, currency: "EUR"),
                carrier: "DemoAir"
            )
        ]
    }
}
