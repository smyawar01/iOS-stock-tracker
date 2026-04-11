import Foundation
import Combine

public protocol WebSocketClientProtocol: AnyObject {
    
    var messagePublisher: AnyPublisher<String, Never> { get }

    func connect()
    func disconnect()
    func send(text: String)
}
