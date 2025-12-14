//
//  SwiftDataStack.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@MainActor
final class SwiftDataStack {
    let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func makeContext() -> ModelContext {
        ModelContext(modelContainer)
    }

    static func makeDefault() -> SwiftDataStack {
        let schema = Schema([
            BookingRecord.self,
            PassengerRecord.self,
            SearchHistoryRecord.self,
            CachedOffersRecord.self,
        ])
        let config = ModelConfiguration(schema: schema)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return SwiftDataStack(modelContainer: container)
    }
}
