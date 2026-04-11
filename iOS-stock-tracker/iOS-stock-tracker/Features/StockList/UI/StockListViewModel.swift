//
//  StockListViewModel.swift
//  iOS-stock-tracker
//
//  Created by Apple on 08/04/2026.
//

import Foundation
import Observation


public struct StockListItemViewData: Hashable {
    
    let symbol: String
    let currentPrice: String
    let priceChange: String
    let description: String
}

@MainActor
public protocol StockListViewModelProtocol {
    var stocks: [StockListItemViewData] { get }
    var isConnected: Bool { get }
    func connect()
    func disconnect()
}

@Observable
public final class StockListViewModel: StockListViewModelProtocol {
    
    public private(set) var stocks: [StockListItemViewData] = StockListItemViewData.mockStocks
    public private(set) var isConnected: Bool = false
    
    @ObservationIgnored
    private var livePriceService: LivePriceServiceProtocol
    
    public init(livePriceService: LivePriceServiceProtocol = LivePriceService()) {
        self.livePriceService = livePriceService
        setupService()
    }
    
    public func connect() {
        let symbols = stocks.map { $0.symbol }
        livePriceService.startTracking(symbols: symbols)
        isConnected = true
    }
    
    public func disconnect() {
        livePriceService.stopTracking()
        isConnected = false
    }
    
    private func setupService() {
        livePriceService.onPriceUpdate = { [weak self] update in
            self?.handlePriceUpdate(update)
        }
        connect()
    }
    
    private func handlePriceUpdate(_ update: PriceUpdate) {
        if let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) {
            let oldData = stocks[index]
            let newData = StockListItemViewData(
                symbol: oldData.symbol,
                currentPrice: update.newPrice,
                priceChange: update.priceChange,
                description: oldData.description
            )
            stocks[index] = newData
        }
    }
}
