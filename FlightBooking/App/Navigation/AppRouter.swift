//
//  AppRouter.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import Observation

enum AppTab: Hashable {
    case search, trips
}

@MainActor
@Observable
final class AppRouter {
    var path: [Route] = []
    var selectedTab: AppTab = .search

    func push(_ route: Route) { path.append(route) }
    func pop() { _ = path.popLast() }
    func resetPath() { path.removeAll() }

    func goToTripsAndReset() {
        selectedTab = .trips
        resetPath()
    }
}

enum Route: Hashable {
    case results(SearchQuery)
    case offerDetails(FlightOffer)
    case booking(FlightOffer)
    case tripDetails(UUID)
}
