import Foundation
import Combine

public final class LivePriceService: LivePriceServiceProtocol {

    // MARK: - LivePriceServiceProtocol

    public var connectionPublisher: AnyPublisher<Bool, Never> {
        webSocketClient.connectionPublisher
    }

    public var priceUpdatePublisher: AnyPublisher<PriceUpdate, Never> {
        priceUpdateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private

    private let priceUpdateSubject = PassthroughSubject<PriceUpdate, Never>()
    private let webSocketClient: WebSocketClientProtocol
    private var symbols: [String] = []
    private var timer: Timer?
    private var cancellable: AnyCancellable?

    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public init(webSocketClient: WebSocketClientProtocol = EchoWebSocketClient()) {
        self.webSocketClient = webSocketClient
        subscribeToMessages()
    }

    // MARK: - LivePriceServiceProtocol

    public func startTracking(symbols: [String]) {
        self.symbols = symbols
        webSocketClient.connect()

        timer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
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

    // MARK: - Private

    private func subscribeToMessages() {
        cancellable = webSocketClient.messagePublisher
            .compactMap { [weak self] text -> PriceUpdate? in
                guard let data = text.data(using: .utf8) else { return nil }
                return try? self?.jsonDecoder.decode(PriceUpdate.self, from: data)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.priceUpdateSubject.send(update)
            }
    }

    private func generateRandomUpdate() {
        guard !symbols.isEmpty else { return }

        let randomSymbol = symbols.randomElement()!
        let basePrice = Double.random(in: 50...500)
        let change = Double.random(in: -10...10)

        let priceString = String(format: "$%.2f", basePrice + change)
        let changeString = String(format: "%+.2f", change)

        let update = PriceUpdate(symbol: randomSymbol, newPrice: priceString, priceChange: changeString)

        if let data = try? jsonEncoder.encode(update),
           let text = String(data: data, encoding: .utf8) {
            webSocketClient.send(text: text)
        }
    }
}
