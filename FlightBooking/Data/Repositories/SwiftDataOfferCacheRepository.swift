//
//  SwiftDataOfferCacheRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@MainActor
final class SwiftDataOfferCacheRepository: OfferCacheRepository {
    private let stack: SwiftDataStack

    init(stack: SwiftDataStack) { self.stack = stack }

    func getCachedOffers(for query: SearchQuery, maxAge: TimeInterval) async throws -> [FlightOffer] {
        let ctx = stack.makeContext()
        let key = query.cacheKey()

        let desc = FetchDescriptor<CachedOffersRecord>(predicate: #Predicate { $0.queryKey == key })
        guard let row = try ctx.fetch(desc).first else { return [] }

        if Date().timeIntervalSince(row.createdAt) > maxAge { return [] }

        return (try? JSONDecoder.iso8601.decode([FlightOffer].self, from: row.offersPayload)) ?? []
    }

    func saveCachedOffers(_ offers: [FlightOffer], for query: SearchQuery) async throws {
        let ctx = stack.makeContext()
        let key = query.cacheKey()
        let payload = try JSONEncoder().encode(offers)

        let desc = FetchDescriptor<CachedOffersRecord>(predicate: #Predicate { $0.queryKey == key })
        if let existing = try ctx.fetch(desc).first {
            existing.createdAt = .now
            existing.offersPayload = payload
        } else {
            ctx.insert(CachedOffersRecord(queryKey: key, createdAt: .now, offersPayload: payload))
        }
        try ctx.save()
    }

    func clearExpired(maxAge: TimeInterval) async throws {
        let ctx = stack.makeContext()
        let cutoff = Date().addingTimeInterval(-maxAge)
        let desc = FetchDescriptor<CachedOffersRecord>(predicate: #Predicate { $0.createdAt < cutoff })
        let rows = try ctx.fetch(desc)
        rows.forEach { ctx.delete($0) }
        try ctx.save()
    }
}
