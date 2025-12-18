//
//  APIClientProtocol.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//
//
//import Foundation
//
//protocol APIClientProtocol {
//    func send<T: Decodable>(_ request: URLRequest) async throws -> T
//}
//
//final class URLSessionAPIClient: APIClientProtocol {
//
//    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
//        var req = request
//
//        // X-Trace-Id (если не задан)
//        if req.value(forHTTPHeaderField: "X-Trace-Id") == nil {
//            req.setValue(UUID().uuidString.lowercased(), forHTTPHeaderField: "X-Trace-Id")
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: req)
//        
//        guard let http = response as? HTTPURLResponse else {
//            throw APIError.badServerResponse
//        }
//        
//        
//        #if DEBUG
//        let trace = req.value(forHTTPHeaderField: "X-Trace-Id") ?? "-"
//        let urlStr = req.url?.absoluteString ?? "-"
//        print("⬅️ \(req.httpMethod ?? "?") \(urlStr)")
//        print("   trace=\(trace) status=\(http.statusCode) bytes=\(data.count)")
//        if let s = String(data: data, encoding: .utf8), !s.isEmpty {
//            print("   body=\(s)")
//        } else {
//            print("   body=<empty>")
//        }
//        #endif
//
//        if !(200..<300).contains(http.statusCode) {
//            let parsedErr = try? JSONDecoder.iso8601.decode(ErrorResponse.self, from: data)
//            throw APIError.httpStatus(http.statusCode, parsedErr)
//        }
//
//        do {
//            return try JSONDecoder.iso8601.decode(T.self, from: data)
//        } catch {
//            throw APIError.decodeFailed(error.localizedDescription)
//        }
//    }
//}

import Foundation

protocol APIClientProtocol {
    func sendRaw(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
    func send<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class URLSessionAPIClient: APIClientProtocol {

    func sendRaw(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var req = request

        if req.value(forHTTPHeaderField: "X-Trace-Id") == nil {
            req.setValue(UUID().uuidString.lowercased(), forHTTPHeaderField: "X-Trace-Id")
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.badServerResponse
        }

        #if DEBUG
        let trace = req.value(forHTTPHeaderField: "X-Trace-Id") ?? "-"
        print("⬅️ \(req.httpMethod ?? "?") \(req.url?.absoluteString ?? "-")")
        print("   trace=\(trace) status=\(http.statusCode) bytes=\(data.count)")
        if let s = String(data: data, encoding: .utf8), !s.isEmpty { print("   body=\(s)") }
        else { print("   body=<empty>") }
        #endif

        if !(200..<300).contains(http.statusCode) {
            let parsedErr = try? JSONDecoder.iso8601.decode(ErrorResponse.self, from: data)
            throw APIError.httpStatus(http.statusCode, parsedErr)
        }

        return (data, http)
    }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await sendRaw(request)
        do {
            return try JSONDecoder.iso8601.decode(T.self, from: data)
        } catch {
            throw APIError.decodeFailed(error.localizedDescription)
        }
    }
}
