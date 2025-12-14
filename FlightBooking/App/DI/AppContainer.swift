//
//  AppContainer.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//

import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let config: AppConfig
    let dataStack: SwiftDataStack

    init(config: AppConfig, dataStack: SwiftDataStack) {
        self.config = config
        self.dataStack = dataStack
    }

    // MARK: - Networking
    lazy var apiClient: APIClientProtocol = URLSessionAPIClient()
    lazy var flightSearchAPI = FlightSearchAPI(baseURL: config.apiBaseURL, client: apiClient)

    // MARK: - Repos
    lazy var flightSearchRepository: FlightSearchRepository = DefaultFlightSearchRepository(api: flightSearchAPI)
    lazy var bookingRepository: BookingRepository = SwiftDataBookingRepository(stack: dataStack)
    lazy var searchHistoryRepository: SearchHistoryRepository = SwiftDataSearchHistoryRepository(stack: dataStack)

    // MARK: - UseCases
    lazy var searchFlightsUseCase = SearchFlightsUseCase(repo: flightSearchRepository, history: searchHistoryRepository)
    lazy var createBookingUseCase = CreateBookingUseCase(repo: bookingRepository)

    // MARK: - VMs
    func makeSearchViewModel(router: AppRouter) -> SearchViewModel {
        SearchViewModel(searchFlights: searchFlightsUseCase, router: router)
    }
    func makeTripsViewModel() -> TripsViewModel {
        TripsViewModel(repo: bookingRepository)
    }
    
    // MARK: - Cache Repository
    lazy var offerCacheRepository: OfferCacheRepository = SwiftDataOfferCacheRepository(stack: dataStack)

    func makeResultsViewModel(query: SearchQuery, router: AppRouter) -> ResultsViewModel {
        ResultsViewModel(
            query: query,
            searchFlights: searchFlightsUseCase,
            cache: offerCacheRepository,
            router: router
        )
    }
    
    // MARK: - Offer Details
    lazy var offerDetailsRepository: OfferDetailsRepository = DefaultOfferDetailsRepository()
    lazy var getOfferDetailsUseCase = GetOfferDetailsUseCase(repo: offerDetailsRepository)

    func makeOfferDetailsViewModel(offer: FlightOffer, router: AppRouter) -> OfferDetailsViewModel {
        OfferDetailsViewModel(offer: offer, getDetails: getOfferDetailsUseCase, router: router)
    }

    func makeBookingViewModel(offer: FlightOffer, router: AppRouter) -> BookingViewModel {
        BookingViewModel(offer: offer, createBooking: createBookingUseCase, router: router)
    }
    
    // MARK: - Trip details & booking cancellation
    lazy var cancelBookingUseCase = CancelBookingUseCase(repo: bookingRepository)

    func makeTripDetailsViewModel(bookingId: UUID, router: AppRouter) -> TripDetailsViewModel {
        TripDetailsViewModel(
            bookingId: bookingId,
            repo: bookingRepository,
            cancelBooking: cancelBookingUseCase,
            router: router
        )
    }


    static func live() -> AppContainer {
        let config = AppConfig(apiBaseURL: URL(string: "https://example.com")!)
        let stack = SwiftDataStack.makeDefault()
        return AppContainer(config: config, dataStack: stack)
    }
}

struct AppConfig {
    let apiBaseURL: URL
}
