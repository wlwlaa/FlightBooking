//
//  OfferCacheRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

protocol OfferCacheRepository {
    func getCachedOffers(for query: SearchQuery, maxAge: TimeInterval) async throws -> [FlightOffer]
    func saveCachedOffers(_ offers: [FlightOffer], for query: SearchQuery) async throws
    func clearExpired(maxAge: TimeInterval) async throws
}
