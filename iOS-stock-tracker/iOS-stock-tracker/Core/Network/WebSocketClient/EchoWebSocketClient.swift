import Foundation
import Combine

public final class EchoWebSocketClient: WebSocketClientProtocol {

    // MARK: - WebSocketClientProtocol

    public var connectionPublisher: AnyPublisher<Bool, Never> {
        connectionSubject.eraseToAnyPublisher()
    }

    public var messagePublisher: AnyPublisher<String, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    // MARK: - Private

    private let connectionSubject = PassthroughSubject<Bool, Never>()
    private let messageSubject = PassthroughSubject<String, Never>()
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)

    public init() {}

    public func connect() {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        connectionSubject.send(true)
        receiveMessage()
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionSubject.send(false)
    }

    public func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                print("WebSocket receiving error: \(error)")
                connectionSubject.send(false)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.messageSubject.send(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.messageSubject.send(text)
                    }
                @unknown default:
                    break
                }
                self.receiveMessage()
            }
        }
    }
}
