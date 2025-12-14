//
//  CachedOffersRecord.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@Model
final class CachedOffersRecord {
    @Attribute(.unique) var queryKey: String
    var createdAt: Date
    var offersPayload: Data

    init(queryKey: String, createdAt: Date, offersPayload: Data) {
        self.queryKey = queryKey
        self.createdAt = createdAt
        self.offersPayload = offersPayload
    }
}
