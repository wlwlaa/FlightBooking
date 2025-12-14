//
//  MockAPIConfig.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 15.12.2025.
//


import Foundation

struct MockAPIConfig {
    var minLatencyMs: Int = 150
    var maxLatencyMs: Int = 650
    var failureRate: Double = 0.08
}

final class MockAPIClient: APIClientProtocol {
    private let cfg: MockAPIConfig

    init(cfg: MockAPIConfig) {
        self.cfg = cfg
    }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        try await simulateLatency()
        try maybeFail()

        guard let url = request.url else { throw APIError.invalidURL }
        let path = url.path

        switch (request.httpMethod ?? "GET", path) {
        case ("POST", "/v1/flights/search"):
            let body = request.httpBody ?? Data()
            let query = try JSONDecoder.iso8601.decode(SearchQuery.self, from: body)

            try validate(query)

            let offers = MockFlights.makeOffers(for: query, count: 30)
            let resp = SearchResponseDTO(offers: offers.map(FlightOfferDTO.fromDomain), nextCursor: nil)
            return try encodeThenDecode(resp)

        default:
            if path.hasPrefix("/v1/offers/") {
                let offerId = String(path.split(separator: "/").last ?? "")
                let dto = MockFlights.makeDetails(forOfferId: offerId)
                return try encodeThenDecode(dto)
            }
            throw APIError.noMockRoute(path)
        }
    }

    private func encodeThenDecode<T: Decodable>(_ value: some Encodable) throws -> T {
        let data = try JSONEncoder.iso8601.encode(value)
        return try JSONDecoder.iso8601.decode(T.self, from: data)
    }

    private func simulateLatency() async throws {
        let lo = max(0, cfg.minLatencyMs)
        let hi = max(lo, cfg.maxLatencyMs)
        let ms = Int.random(in: lo...hi)
        try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
    }

    private func maybeFail() throws {
        if cfg.failureRate > 0, Double.random(in: 0...1) < cfg.failureRate {
            throw URLError(.timedOut)
        }
    }

    private func validate(_ q: SearchQuery) throws {
        if q.fromIATA.count != 3 || q.toIATA.count != 3 {
            throw APIError.httpStatus(422, "IATA must be 3 letters")
        }
        if q.adults < 1 || q.adults > 9 {
            throw APIError.httpStatus(422, "adults must be 1...9")
        }
    }
}

private enum MockFlights {
    static func makeOffers(for q: SearchQuery, count: Int) -> [FlightOffer] {
        let seed = stableHash(q.cacheKey())
        var rng = LCRNG(seed: UInt64(seed))

        let carriers = ["Finnair", "Lufthansa", "KLM", "Air France", "British Airways", "SAS", "Ryanair", "Wizz Air"]
        let dayStart = Calendar(identifier: .gregorian).startOfDay(for: q.departDate)

        return (0..<count).map { i in
            let depHour = 6 + (i % 12)
            let depMin = [0, 10, 15, 25, 40, 55][Int(rng.next() % 6)]
            let depart = Calendar.current.date(byAdding: .minute, value: depHour * 60 + depMin, to: dayStart) ?? dayStart

            let durMin = 65 + Int(rng.next() % 360) // 1h..7h
            let arrive = depart.addingTimeInterval(TimeInterval(durMin * 60))

            let carrier = carriers[Int(rng.next() % UInt64(carriers.count))]

            let cabinMult: Decimal = switch q.cabin {
            case .economy: 1.0
            case .premiumEconomy: 1.35
            case .business: 2.1
            case .first: 3.2
            }

            let base = Decimal(70 + Int(rng.next() % 180)) + Decimal(durMin) * 0.12
            let total = (base * cabinMult) * Decimal(q.adults)

            let id = "\(q.fromIATA.uppercased())\(q.toIATA.uppercased())-\(dayKey(dayStart))-\(i)"

            return FlightOffer(
                id: id,
                fromIATA: q.fromIATA.uppercased(),
                toIATA: q.toIATA.uppercased(),
                departAt: depart,
                arriveAt: arrive,
                price: Money(amount: total.rounded2(), currency: "EUR"),
                carrier: carrier
            )
        }
    }

    static func makeDetails(forOfferId id: String) -> OfferDetailsDTO {
        let h = stableHash(id)
        let tier = abs(h) % 3

        let fareName: String? = switch tier {
        case 0: "Light"
        case 1: "Standard"
        default: "Flex"
        }

        let baggage: [String] = switch tier {
        case 0: ["Personal item"]
        case 1: ["Personal item", "Cabin bag (8kg)"]
        default: ["Personal item", "Cabin bag (8kg)", "Checked bag (23kg)"]
        }

        let refundable: Bool? = (tier == 2)
        let changeFee: MoneyDTO? = (tier == 2) ? MoneyDTO(amount: 0, currency: "EUR") : MoneyDTO(amount: 35, currency: "EUR")

        let rules = [
            "ID must match passenger name",
            tier == 2 ? "Changes allowed (no fee)" : "Changes allowed with fee",
            refundable == true ? "Refundable" : "Non-refundable"
        ]

        return OfferDetailsDTO(
            fareName: fareName,
            baggage: baggage,
            rules: rules,
            refundable: refundable,
            changeFee: changeFee
        )
    }

    private static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyyMMdd"
        return f.string(from: date)
    }

    private static func stableHash(_ s: String) -> Int {
        var h: UInt64 = 1469598103934665603
        for b in s.utf8 {
            h ^= UInt64(b)
            h &*= 1099511628211
        }
        return Int(truncatingIfNeeded: h)
    }

    private struct LCRNG {
        var state: UInt64
        init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1
            return state
        }
    }
}

private extension Decimal {
    func rounded2() -> Decimal {
        var x = self
        var r = Decimal()
        NSDecimalRound(&r, &x, 2, .bankers)
        return r
    }
}
