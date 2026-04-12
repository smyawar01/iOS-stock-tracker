import XCTest
import Combine
@testable import iOS_stock_tracker

final class EchoWebSocketClientTests: XCTestCase {

    var sut: EchoWebSocketClient!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = EchoWebSocketClient()
        cancellables = []
    }
    
    override func tearDown() {
        sut.disconnect()
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_connectAndSend_receivesEchoedMessage() {
        // Arrange
        let expectation = XCTestExpectation(description: "Wait for message to be echoed from postman")
        let messageToSend = "Hello WebSocket"
        var receivedMessage: String?
        
        sut.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        // Act
        sut.connect()
        
        // Allow time for the socket handshake to complete before sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.sut.send(text: messageToSend)
        }
        
        // Assert
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(receivedMessage, messageToSend, "The sent message should be echoed back exactly")
    }
    
    func test_connectionPublisher_emitsConnectedAndDisconnectedStates() {
        // Arrange
        let connectedExpectation = XCTestExpectation(description: "Should emit true when connected")
        let disconnectedExpectation = XCTestExpectation(description: "Should emit false when disconnected")
        
        var connectionStates: [Bool] = []
        
        sut.connectionPublisher
            .sink { isConnected in
                connectionStates.append(isConnected)
                if isConnected {
                    connectedExpectation.fulfill()
                } else {
                    disconnectedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        // Act
        sut.connect()
        wait(for: [connectedExpectation], timeout: 3.0)
        
        sut.disconnect()
        wait(for: [disconnectedExpectation], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(connectionStates, [true, false], "Should emit connected=true, then connected=false")
    }
}
