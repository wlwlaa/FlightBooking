import Foundation

final class OfferDetailsAPI {
    let baseURL: URL
    let client: APIClientProtocol

    init(baseURL: URL, client: APIClientProtocol) {
        self.baseURL = baseURL
        self.client = client
    }

    func getDetails(offerId: String) async throws -> OfferDetailsDTO {
        let req = URLRequest(url: baseURL.appendingPathComponent("/v1/offers/\(offerId)"))
        return try await client.send(req)
    }
}
