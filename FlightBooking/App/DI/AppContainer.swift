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
    
    // Базовый клиент без "identity-aware" обвязки, чтобы не было рекурсии при guestAuth
    lazy var rawHTTPClient: any APIClientProtocol = {
        // if config.useMockAPI { return MockAPIClient(cfg: config.mock) }
        return URLSessionAPIClient()
    }()

    // MARK: - Networking
    lazy var apiClient: any APIClientProtocol = {
        let bookingPorts: Set<Int> = [8084]

        func port(of url: URL?) -> Int? { url?.port }

        return IdentityAwareAPIClient(
            base: rawHTTPClient,
            deviceIdProvider: deviceIdProvider,
            identity: identityManager,
            shouldAttachIdentity: { req in
                // bearer нужен для booking/payments (и можно для /v1/me, но там мы ходим через identityAPI)
                if let p = port(of: req.url) { return bookingPorts.contains(p) }
                return false
            },
            shouldAttachDeviceId: { req in
                // X-Device-Id нужен для booking/payments
                if let p = port(of: req.url) { return bookingPorts.contains(p) }
                return false
            },
            shouldAttachIdempotency: { req in
                guard let method = req.httpMethod?.uppercased() else { return false }
                let isWrite = ["POST","PUT","PATCH","DELETE"].contains(method)
                guard isWrite else { return false }
                if let p = port(of: req.url) { return bookingPorts.contains(p) }
                return false
            }
        )
    }()

    // MARK: - API
    lazy var flightSearchAPI = FlightSearchAPI(baseURL: config.offersBaseURL, client: apiClient)
    lazy var offerDetailsAPI = OfferDetailsAPI(baseURL: config.offersBaseURL, client: apiClient)
    lazy var locationsAPI = LocationsAPI(baseURL: config.catalogBaseURL, client: apiClient)
    lazy var bookingsAPI = BookingsAPI(baseURL: config.bookingBaseURL, client: apiClient)
    lazy var identityAPI = IdentityAPI(baseURL: config.identityBaseURL, client: rawHTTPClient)
    lazy var paymentsAPI = PaymentsAPI(baseURL: config.bookingBaseURL, client: apiClient)
    
    // MARK: - Identity
    lazy var deviceIdProvider = DeviceIdProvider()
    lazy var identityManager = IdentityManager(deviceIdProvider: deviceIdProvider, api: identityAPI)

    // MARK: - Repos
    lazy var flightSearchRepository: FlightSearchRepository = DefaultFlightSearchRepository(api: flightSearchAPI)
    lazy var bookingRepository: BookingRepository = RemoteBookingRepository(api: bookingsAPI)
    lazy var searchHistoryRepository: SearchHistoryRepository = SwiftDataSearchHistoryRepository(stack: dataStack)
    lazy var offerCacheRepository: OfferCacheRepository = SwiftDataOfferCacheRepository(stack: dataStack)
    lazy var offerDetailsRepository: OfferDetailsRepository = DefaultOfferDetailsRepository(api: offerDetailsAPI)
    lazy var paymentRepository: PaymentRepository = RemotePaymentRepository(api: paymentsAPI)

    // MARK: - UseCases
    lazy var searchFlightsUseCase = SearchFlightsUseCase(repo: flightSearchRepository, history: searchHistoryRepository)
    lazy var continueSearchFlightsUseCase = ContinueSearchFlightsUseCase(repo: flightSearchRepository)
    
    lazy var getOfferDetailsUseCase = GetOfferDetailsUseCase(repo: offerDetailsRepository)
    lazy var priceCheckOfferUseCase = PriceCheckOfferUseCase(repo: offerDetailsRepository)
    
    lazy var confirmBookingUseCase = ConfirmBookingUseCase(repo: bookingRepository)
    lazy var cancelBookingUseCase = CancelBookingUseCase(repo: bookingRepository)
    lazy var createBookingUseCase = CreateBookingUseCase(repo: bookingRepository)
    
    lazy var createPaymentIntentUseCase = CreatePaymentIntentUseCase(repo: paymentRepository)

    // MARK: - VMs
    func makeSearchViewModel(router: AppRouter) -> SearchViewModel {
        SearchViewModel(searchFlights: searchFlightsUseCase, router: router)
    }

    func makeResultsViewModel(query: SearchQuery, router: AppRouter) -> ResultsViewModel {
        ResultsViewModel(
            query: query,
            searchFlights: searchFlightsUseCase,
            continueSearch: continueSearchFlightsUseCase,
            cache: offerCacheRepository,
            router: router
        )
    }
    
    func makeOfferDetailsViewModel(offer: FlightOffer, router: AppRouter) -> OfferDetailsViewModel {
        OfferDetailsViewModel(
            offer: offer,
            getDetails: getOfferDetailsUseCase,
            priceCheck: priceCheckOfferUseCase,
            router: router
        )
    }

    func makeTripDetailsViewModel(bookingId: UUID, router: AppRouter) -> TripDetailsViewModel {
        TripDetailsViewModel(
            bookingId: bookingId,
            repo: bookingRepository,
            cancelBooking: cancelBookingUseCase,
            router: router
        )
    }
    
    func makeTripsViewModel() -> TripsViewModel {
        TripsViewModel(repo: bookingRepository)
    }
    
    func makeBookingViewModel(offer: FlightOffer, router: AppRouter) -> BookingViewModel {
        BookingViewModel(
            offer: offer,
            createBooking: createBookingUseCase,
            createPaymentIntent: createPaymentIntentUseCase,
            confirmBooking: confirmBookingUseCase,
            router: router
        )
    }
    

    static func live() -> AppContainer {
        let env = ProcessInfo.processInfo.environment
        let useMock = (env["USE_MOCK_API"] == "1") || (env["USE_MOCK_API"] == "true")

        let config = AppConfig(
            identityBaseURL: URL(string: "http://localhost:8081")!,
            catalogBaseURL: URL(string: "http://localhost:8082")!,
            offersBaseURL: URL(string: "http://localhost:8083")!,
            bookingBaseURL: URL(string: "http://localhost:8084")!,
            useMockAPI: useMock,
            // mock: MockAPIConfig()
        )

        let stack = SwiftDataStack.makeDefault()
        return AppContainer(config: config, dataStack: stack)
    }
}
