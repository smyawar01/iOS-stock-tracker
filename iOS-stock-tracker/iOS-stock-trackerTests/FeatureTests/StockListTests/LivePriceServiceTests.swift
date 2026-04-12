import XCTest
import Combine
@testable import iOS_stock_tracker

final class LivePriceServiceTests: XCTestCase {

    var sut: LivePriceService!
    var mockWebSocketClient: MockWebSocketClient!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockWebSocketClient = MockWebSocketClient()
        sut = LivePriceService(webSocketClient: mockWebSocketClient)
        cancellables = []
    }
    
    override func tearDown() {
        sut.stopTracking()
        sut = nil
        mockWebSocketClient = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_startTracking_connectsWebSocketAndSendsUpdates() {
        // Arrange
        let symbols = ["AAPL", "GOOG"]
        XCTAssertFalse(mockWebSocketClient.didConnect)
        XCTAssertTrue(mockWebSocketClient.sentMessages.isEmpty)
        
        let expectation = XCTestExpectation(description: "Wait for timer to trigger random update")
        
        // Act
        sut.startTracking(symbols: symbols)
        
        // Assert - immediate connection
        XCTAssertTrue(mockWebSocketClient.didConnect, "startTracking should immediately call connect() on WebSocketClient")
        
        // Wait for the timer (1.5 seconds) to trigger at least one random update
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.mockWebSocketClient.sentMessages.isEmpty {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertFalse(mockWebSocketClient.sentMessages.isEmpty, "Timer should have fired and sent at least one update to the web socket")
    }
    
    func test_stopTracking_disconnectsWebSocketAndStopsTimer() {
        // Arrange
        sut.startTracking(symbols: ["AAPL"])
        mockWebSocketClient.didDisconnect = false
        
        // Act
        sut.stopTracking()
        
        // Assert
        XCTAssertTrue(mockWebSocketClient.didDisconnect, "stopTracking should call disconnect() on WebSocketClient")
        
        // Ensure no messages are sent over time after stopping
        let expectation = XCTestExpectation(description: "Ensure no updates happen")
        expectation.isInverted = true // We want the timeout to succeed without fulfillment
        
        mockWebSocketClient.sentMessages.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.mockWebSocketClient.sentMessages.isEmpty {
                expectation.fulfill() // Fall into inverted failure
            }
        }
        wait(for: [expectation], timeout: 2.5)
    }
    
    func test_incomingMessage_decodesToPriceUpdatePublisher() async throws {
        // Arrange
        let updateExpectation = XCTestExpectation(description: "Should receive decoded PriceUpdate")
        var receivedUpdate: PriceUpdate?
        
        let validJSONMessage = """
        {
            "symbol": "TSLA",
            "newPrice": "$245.50",
            "priceChange": "+5.50"
        }
        """
        
        sut.priceUpdatePublisher
            .sink { update in
                receivedUpdate = update
                updateExpectation.fulfill()
            }
            .store(in: &cancellables)
            
        // Act
        mockWebSocketClient.messageSubject.send(validJSONMessage)
        
        // Expectation
        await fulfillment(of: [updateExpectation], timeout: 1.0)
        
        // Assert
        XCTAssertNotNil(receivedUpdate)
        XCTAssertEqual(receivedUpdate?.symbol, "TSLA")
        XCTAssertEqual(receivedUpdate?.newPrice, "$245.50")
        XCTAssertEqual(receivedUpdate?.priceChange, "+5.50")
    }
    
    func test_connectionPublisher_forwardsWebSocketConnectionState() async throws {
        // Arrange
        var receivedStates: [Bool] = []
        let connectedExpectation = XCTestExpectation(description: "Wait for connected")
        let disconnectedExpectation = XCTestExpectation(description: "Wait for disconnected")
        
        sut.connectionPublisher
            .sink { isConnected in
                receivedStates.append(isConnected)
                if isConnected {
                    connectedExpectation.fulfill()
                } else {
                    disconnectedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        // Act
        mockWebSocketClient.connectionSubject.send(true)
        await fulfillment(of: [connectedExpectation], timeout: 1.0)
        
        mockWebSocketClient.connectionSubject.send(false)
        await fulfillment(of: [disconnectedExpectation], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(receivedStates, [true, false])
    }
}
