import Foundation

public protocol WebSocketClientProtocol: AnyObject {
    var onReceive: ((String) -> Void)? { get set }
    
    func connect()
    func disconnect()
    func send(text: String)
}
