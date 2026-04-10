import Foundation

public final class LivePriceService: LivePriceServiceProtocol {
    public var onPriceUpdate: ((PriceUpdate) -> Void)?
    
    private let webSocketClient: WebSocketClientProtocol
    private var symbols: [String] = []
    private var timer: Timer?
    
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    public init(webSocketClient: WebSocketClientProtocol = EchoWebSocketClient()) {
        self.webSocketClient = webSocketClient
        
        self.webSocketClient.onReceive = { [weak self] text in
            self?.handleReceivedMessage(text)
        }
    }
    
    public func startTracking(symbols: [String]) {
        self.symbols = symbols
        webSocketClient.connect()
        
        // Use a timer on the main runloop to continually fire updates
        timer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
                self?.generateRandomUpdate()
            }
        }
    }
    
    public func stopTracking() {
        timer?.invalidate()
        timer = nil
        webSocketClient.disconnect()
        symbols.removeAll()
    }
    
    private func generateRandomUpdate() {
        guard !symbols.isEmpty else { return }
        
        let randomSymbol = symbols.randomElement()!
        
        let basePrice = Double.random(in: 50...500)
        let change = Double.random(in: -10...10)
        let newPrice = basePrice + change
        
        let priceString = String(format: "$%.2f", newPrice)
        let changeString = String(format: "%+.2f", change)
        
        let update = PriceUpdate(symbol: randomSymbol, newPrice: priceString, priceChange: changeString)
        
        if let data = try? jsonEncoder.encode(update),
           let text = String(data: data, encoding: .utf8) {
            webSocketClient.send(text: text)
        }
    }
    
    private func handleReceivedMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        if let update = try? jsonDecoder.decode(PriceUpdate.self, from: data) {
            DispatchQueue.main.async { [weak self] in
                self?.onPriceUpdate?(update)
            }
        }
    }
}
