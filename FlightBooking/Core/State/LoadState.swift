//
//  LoadState.swift
//  FlightBooking
//
//  Created by Андрей Гацко on 14.12.2025.
//


import Foundation

enum LoadState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(String)
}
