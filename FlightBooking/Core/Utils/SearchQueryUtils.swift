//
//  SearchQuery.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation

extension SearchQuery {
    func cacheKey() -> String {
        let from = fromIATA.uppercased()
        let to = toIATA.uppercased()
        let depart = Self.dayString(departDate)
        let ret = returnDate.map(Self.dayString) ?? "none"
        return "\(from)|\(to)|\(depart)|\(ret)|\(adults)|\(cabin.rawValue)"
    }

    private static func dayString(_ date: Date) -> String {
        let d = Calendar(identifier: .gregorian).startOfDay(for: date)
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }
}
