//
//  BookingRecord.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@Model
final class BookingRecord {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var statusRaw: String

    // Быстрые поля для списков
    var fromIATA: String
    var toIATA: String
    var departAt: Date
    var arriveAt: Date
    var priceAmount: Decimal
    var priceCurrency: String
    var carrier: String

    // Полный snapshot оффера (на будущее: правила тарифа/сегменты)
    var offerPayload: Data?

    @Relationship(deleteRule: .cascade, inverse: \PassengerRecord.booking)
    var passengers: [PassengerRecord] = []

    init(
        id: UUID,
        createdAt: Date,
        statusRaw: String,
        fromIATA: String,
        toIATA: String,
        departAt: Date,
        arriveAt: Date,
        priceAmount: Decimal,
        priceCurrency: String,
        carrier: String,
        offerPayload: Data?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.statusRaw = statusRaw
        self.fromIATA = fromIATA
        self.toIATA = toIATA
        self.departAt = departAt
        self.arriveAt = arriveAt
        self.priceAmount = priceAmount
        self.priceCurrency = priceCurrency
        self.carrier = carrier
        self.offerPayload = offerPayload
    }
}


//extension BookingRecord: Identifiable {}
