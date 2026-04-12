import Foundation
import Combine

public protocol LivePriceServiceProtocol: AnyObject {
    /// Mirrors the WebSocket connection state — `true` connected, `false` disconnected.
    var connectionPublisher: AnyPublisher<Bool, Never> { get }
    var priceUpdatePublisher: AnyPublisher<PriceUpdate, Never> { get }
    func startTracking(symbols: [String])
    func stopTracking()
}
