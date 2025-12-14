//
//  FlightBookingApp.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import SwiftUI
import SwiftData

@main
struct FlightBookingApp: App {
    @State private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
        .modelContainer(container.dataStack.modelContainer)
    }
}
