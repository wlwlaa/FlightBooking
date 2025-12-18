//
//  BookingsAPI.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class BookingsAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func createDraft(_ body: CreateBookingRequestDTO) async throws -> BookingResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/bookings"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.iso8601.encode(body)

        let (data, http) = try await client.sendRaw(req)

        // 1) Нормальный кейс: сервер вернул JSON
        if !data.isEmpty {
            do {
                return try JSONDecoder.iso8601.decode(BookingResponseDTO.self, from: data)
            } catch {
                throw APIError.decodeFailed(error.localizedDescription)
            }
        }

        // 2) Сервер вернул пустое тело — пробуем Location
        if let loc = http.value(forHTTPHeaderField: "Location") ?? http.value(forHTTPHeaderField: "location"),
           let url = URL(string: loc),
           let last = url.path.split(separator: "/").last,
           let bookingId = UUID(uuidString: String(last)) {
            return try await get(id: bookingId)
        }

        // 3) Фолбэк: берём самый свежий draft и подтягиваем детали
        let from = Date().addingTimeInterval(-5 * 60)
        let page = try await list(status: .draft, from: from, to: nil, cursor: nil, limit: 20)

        guard let newest = page.items.max(by: { $0.createdAt < $1.createdAt }) else {
            throw APIError.decodeFailed("Create booking succeeded but server returned empty body and list is empty.")
        }

        return try await get(id: newest.id)
    }

    func list(
        status: BookingStatus?,
        from: Date?,
        to: Date?,
        cursor: String?,
        limit: Int?
    ) async throws -> BookingListResponseDTO {
        var comps = URLComponents(url: baseURL.appendingPathComponent("v1/bookings"), resolvingAgainstBaseURL: false)!
        var q: [URLQueryItem] = []
        if let status { q.append(.init(name: "status", value: status.rawValue)) }
        if let from { q.append(.init(name: "from", value: ISO8601DateFormatter().string(from: from))) }
        if let to { q.append(.init(name: "to", value: ISO8601DateFormatter().string(from: to))) }
        if let cursor { q.append(.init(name: "cursor", value: cursor)) }
        if let limit { q.append(.init(name: "limit", value: String(limit))) }
        comps.queryItems = q.isEmpty ? nil : q

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        return try await client.send(req)
    }

    func get(id: UUID) async throws -> BookingResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/bookings/\(id.uuidString)"))
        req.httpMethod = "GET"
        return try await client.send(req)
    }
    
    func confirm(id: UUID) async throws -> BookingResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/bookings/\(id.uuidString)/confirm"))
        req.httpMethod = "POST"

        let (data, _) = try await client.sendRaw(req)
        if !data.isEmpty {
            return try JSONDecoder.iso8601.decode(BookingResponseDTO.self, from: data)
        }
        return try await get(id: id) // fallback если сервер вернёт пустое тело
    }
    
    func cancel(id: UUID) async throws -> BookingResponseDTO {
        var req = URLRequest(url: baseURL.appendingPathComponent("v1/bookings/\(id.uuidString)/cancel"))
        req.httpMethod = "POST"

        let (data, _) = try await client.sendRaw(req)

        if !data.isEmpty {
            return try JSONDecoder.iso8601.decode(BookingResponseDTO.self, from: data)
        }

        // если сервер вернул пустое тело
        return try await get(id: id)
    }
}
