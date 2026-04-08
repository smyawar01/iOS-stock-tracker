//
//  StockListViewModel.swift
//  iOS-stock-tracker
//
//  Created by Apple on 08/04/2026.
//

import Foundation
import Observation

@MainActor
public protocol StockListViewModelProtocol {
    var stocks: [String] { get }
}

public final class StockListViewModel: StockListViewModelProtocol {
    
    public private(set) var stocks: [String] = ["AAPL", "GOOG", "TSLA", "AMZN"]
}
