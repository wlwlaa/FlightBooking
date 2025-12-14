//
//  SearchHistoryRecord.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@Model
final class SearchHistoryRecord {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var queryPayload: Data

    init(id: UUID, createdAt: Date, queryPayload: Data) {
        self.id = id
        self.createdAt = createdAt
        self.queryPayload = queryPayload
    }
}
