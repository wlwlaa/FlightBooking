//
//  SwiftDataSearchHistoryRepository.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation
import SwiftData

@MainActor
final class SwiftDataSearchHistoryRepository: SearchHistoryRepository {
    private let stack: SwiftDataStack

    init(stack: SwiftDataStack) { self.stack = stack }

    func save(_ query: SearchQuery) async throws {
        let ctx = stack.makeContext()
        let payload = try JSONEncoder().encode(query)
        ctx.insert(SearchHistoryRecord(id: UUID(), createdAt: .now, queryPayload: payload))
        try ctx.save()
    }

    func latest(limit: Int) async throws -> [SearchQuery] {
        let ctx = stack.makeContext()
        var desc = FetchDescriptor<SearchHistoryRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        desc.fetchLimit = limit
        let rows = try ctx.fetch(desc)
        return rows.compactMap { try? JSONDecoder().decode(SearchQuery.self, from: $0.queryPayload) }
    }
}
