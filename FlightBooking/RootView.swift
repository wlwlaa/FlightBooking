//
//  ContentView.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//
import SwiftUI

struct RootView: View {
    let container: AppContainer
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $router.selectedTab) {
                SearchView(vm: container.makeSearchViewModel(router: router))
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(AppTab.search)

                TripsView()
                    .tabItem { Label("Trips", systemImage: "airplane") }
                    .tag(AppTab.trips)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .results(let query):
                    ResultsView(vm: container.makeResultsViewModel(query: query, router: router))
                case .offerDetails(let offer):
                    OfferDetailsView(vm: container.makeOfferDetailsViewModel(offer: offer, router: router))
                case .booking(let offer):
                    BookingView(vm: container.makeBookingViewModel(offer: offer, router: router))
                case .tripDetails(let id):
                    TripDetailsView(vm: container.makeTripDetailsViewModel(bookingId: id, router: router))
                }
            }
        }
    }
}

