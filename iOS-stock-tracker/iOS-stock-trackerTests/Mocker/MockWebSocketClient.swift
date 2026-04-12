//
//  MockWebSocketClient.swift
//  iOS-stock-tracker
//
//  Created by Apple on 12/04/2026.
//
import Combine

final class MockWebSocketClient: WebSocketClientProtocol {
    let connectionSubject = PassthroughSubject<Bool, Never>()
    let messageSubject = PassthroughSubject<String, Never>()
    
    var connectionPublisher: AnyPublisher<Bool, Never> { connectionSubject.eraseToAnyPublisher() }
    var messagePublisher: AnyPublisher<String, Never> { messageSubject.eraseToAnyPublisher() }
    
    var didConnect = false
    var didDisconnect = false
    var sentMessages: [String] = []

    func connect() {
        didConnect = true
    }
    
    func disconnect() {
        didDisconnect = true
    }
    
    func send(text: String) {
        sentMessages.append(text)
    }
}
