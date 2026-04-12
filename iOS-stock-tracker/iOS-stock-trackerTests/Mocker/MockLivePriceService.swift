//
//  MockLivePriceService.swift
//  iOS-stock-tracker
//
//  Created by Apple on 12/04/2026.
//
import XCTest
import Combine
@testable import iOS_stock_tracker

final class MockLivePriceService: LivePriceServiceProtocol {
    let connectionSubject = PassthroughSubject<Bool, Never>()
    let priceUpdateSubject = PassthroughSubject<PriceUpdate, Never>()

    var connectionPublisher: AnyPublisher<Bool, Never> { connectionSubject.eraseToAnyPublisher() }
    var priceUpdatePublisher: AnyPublisher<PriceUpdate, Never> { priceUpdateSubject.eraseToAnyPublisher() }

    var trackedSymbols: [String] = []
    var didCallStartTracking = false
    var didCallStopTracking = false

    func startTracking(symbols: [String]) {
        didCallStartTracking = true
        trackedSymbols = symbols
    }

    func stopTracking() {
        didCallStopTracking = true
    }
}
