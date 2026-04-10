import Foundation


public protocol LivePriceServiceProtocol {
    var onPriceUpdate: ((PriceUpdate) -> Void)? { get set }
    func startTracking(symbols: [String])
    func stopTracking()
}
