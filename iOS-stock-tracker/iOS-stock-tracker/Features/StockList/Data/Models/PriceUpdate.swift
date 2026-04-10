import Foundation

public struct PriceUpdate: Codable {
    public let symbol: String
    public let newPrice: String
    public let priceChange: String
    
    public init(symbol: String, newPrice: String, priceChange: String) {
        self.symbol = symbol
        self.newPrice = newPrice
        self.priceChange = priceChange
    }
}
