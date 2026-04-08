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
}

public final class StockListViewModel: StockListViewModelProtocol {
    
    public private(set) var stocks: [StockListItemViewData] = StockListItemViewData.mockStocks
}
