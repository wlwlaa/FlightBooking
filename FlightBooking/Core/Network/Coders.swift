//
//  Codes.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 15.12.2025.
//

import Foundation

extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let d = JSONDecoder()

        let fFrac = ISO8601DateFormatter()
        fFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fStd = ISO8601DateFormatter()
        fStd.formatOptions = [.withInternetDateTime]

        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            if let date = fFrac.date(from: s) ?? fStd.date(from: s) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid ISO8601 date: \(s)")
        }

        return d
    }
}

extension JSONEncoder {
    static var iso8601: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
}
