import Foundation

public final class EchoWebSocketClient: WebSocketClientProtocol {
    public var onReceive: ((String) -> Void)?
    
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    
    public init() {}
    
    public func connect() {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
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
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("WebSocket receiving error: \(error)")
                // Reconnect logic or just log in a real app
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onReceive?(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.onReceive?(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue listening
                self.receiveMessage()
            }
        }
    }
}
