//
//  StockListViewModel.swift
//  iOS-stock-tracker
//
//  Created by Apple on 08/04/2026.
//

import Foundation
import Combine
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
    func sort(filter: StockSortOption)
}

@Observable
public final class StockListViewModel: StockListViewModelProtocol {
    
    @ObservationIgnored
    private var livePriceService: LivePriceServiceProtocol
    @ObservationIgnored
    private var cancellables: Set<AnyCancellable> = []
    private var selectedSort: StockSortOption = .price
    
    public var stocks: [StockListItemViewData] = StockListItemViewData.mockStocks
    public private(set) var isConnected: Bool = false
    
    public init(livePriceService: LivePriceServiceProtocol = LivePriceService()) {
        self.livePriceService = livePriceService
        setupService()
    }
    
    public func connect() {
        let symbols = stocks.map { $0.symbol }
        livePriceService.startTracking(symbols: symbols)
    }
    
    public func disconnect() {
        livePriceService.stopTracking()
    }
    
    public func sort(filter: StockSortOption) {
        selectedSort = filter
        switch filter {
        case .price:
            stocks = stocks.sorted { $0.numericPrice > $1.numericPrice }
        case .priceChange:
            stocks = stocks.sorted { $0.numericChange > $1.numericChange }
        }
    }
    
    private func setupService() {
        livePriceService.priceUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handlePriceUpdate(update)
            }
            .store(in: &cancellables)
            
        livePriceService.connectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnected = connected
            }
            .store(in: &cancellables)
            
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
            sort(filter: selectedSort)
        }
    }
}
