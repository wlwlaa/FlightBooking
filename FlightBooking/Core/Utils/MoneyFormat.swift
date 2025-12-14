//
//  MoneyFormat.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

extension Money {
    func formatted() -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency
        let n = NSDecimalNumber(decimal: amount)
        return f.string(from: n) ?? "\(amount) \(currency)"
    }
}
