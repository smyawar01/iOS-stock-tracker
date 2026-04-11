import Foundation

public enum StockSortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case priceChange = "Change"

    public var id: String { rawValue }
}

public extension StockListItemViewData {
    /// Numeric price value parsed from formatted string e.g. "$175.32" → 175.32
    var numericPrice: Double {
        Double(currentPrice.replacingOccurrences(of: "$", with: "")) ?? 0
    }

    /// Numeric change value parsed from formatted string e.g. "+1.25" or "-0.85" → ±Double
    var numericChange: Double {
        Double(priceChange.replacingOccurrences(of: "+", with: "")) ?? 0
    }
}
