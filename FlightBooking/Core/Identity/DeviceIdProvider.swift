//
//  DeviceIdProvider.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 18.12.2025.
//


import Foundation

final class DeviceIdProvider {
    private let key = "fb_device_id"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var deviceId: String {
        if let v = defaults.string(forKey: key), v.count >= 3 { return v }
        let v = "ios-\(UUID().uuidString.lowercased())"
        defaults.set(v, forKey: key)
        return v
    }
}