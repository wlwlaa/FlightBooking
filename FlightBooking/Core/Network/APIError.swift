import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case httpStatus(Int, String?)
    case decodeFailed(String)
    case noMockRoute(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpStatus(let code, let msg): return "HTTP \(code)\(msg.map { ": \($0)" } ?? "")"
        case .decodeFailed(let msg): return "Decode failed: \(msg)"
        case .noMockRoute(let path): return "No mock route for \(path)"
        }
    }
}
