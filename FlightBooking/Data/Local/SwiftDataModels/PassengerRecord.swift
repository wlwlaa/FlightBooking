//
//  PassengerRecord.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation
import SwiftData

@Model
final class PassengerRecord {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var birthDate: Date
    var documentNumber: String?

    var booking: BookingRecord?

    init(id: UUID, firstName: String, lastName: String, birthDate: Date, documentNumber: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.documentNumber = documentNumber
    }
}
