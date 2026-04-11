import Foundation
import Combine

public protocol LivePriceServiceProtocol: AnyObject {
    var priceUpdatePublisher: AnyPublisher<PriceUpdate, Never> { get }
    func startTracking(symbols: [String])
    func stopTracking()
}
