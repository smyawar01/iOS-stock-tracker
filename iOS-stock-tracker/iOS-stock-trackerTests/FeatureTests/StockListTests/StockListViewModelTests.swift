import XCTest
import Combine
@testable import iOS_stock_tracker

@MainActor
final class StockListViewModelTests: XCTestCase {

    var sut: StockListViewModel!
    var mockService: MockLivePriceService!

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockLivePriceService()
        sut = StockListViewModel(livePriceService: mockService)
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        try await super.tearDown()
    }

    func test_initialization_startsTracking() {
        // Assert
        XCTAssertTrue(mockService.didCallStartTracking)
        XCTAssertFalse(mockService.trackedSymbols.isEmpty)
        XCTAssertEqual(mockService.trackedSymbols.count, sut.stocks.count)
    }

    func test_disconnect_stopsTracking() {
        // Act
        sut.disconnect()
        
        // Assert
        XCTAssertTrue(mockService.didCallStopTracking)
    }
    
    func test_connect_startsTracking() {
        // Act
        sut.disconnect()
        mockService.didCallStartTracking = false // reset after init
        
        sut.connect()
        
        // Assert
        XCTAssertTrue(mockService.didCallStartTracking)
    }

    func test_sort_byPrice_sortsDescending() {
        
        // Act
        sut.sort(filter: .price)
        
        // Assert
        let sorted = sut.stocks
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(sorted[i].numericPrice, sorted[i+1].numericPrice)
        }
    }

    func test_sort_byPriceChange_sortsDescending() {
        // Act
        sut.sort(filter: .priceChange)
        
        // Assert
        let sorted = sut.stocks
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(sorted[i].numericChange, sorted[i+1].numericChange)
        }
    }

    func test_priceUpdatePublisher_updatesMatchingStockAndMaintainsSort() async throws {
        // Arrange
        sut.sort(filter: .price)
        
        let stockToUpdate = sut.stocks[0]
        let originalPrice = stockToUpdate.numericPrice
        
        let newPriceStr = String(format: "$%.2f", originalPrice + 500.0)
        
        let update = PriceUpdate(
            symbol: stockToUpdate.symbol,
            newPrice: newPriceStr,
            priceChange: "+50.0"
        )
        
        // Act
        mockService.priceUpdateSubject.send(update)
        
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Assert
        let updatedStock = sut.stocks.first(where: { $0.symbol == stockToUpdate.symbol })
        XCTAssertNotNil(updatedStock)
        XCTAssertEqual(updatedStock?.currentPrice, newPriceStr)
        XCTAssertEqual(updatedStock?.priceChange, "+50.0")
        
        // Ensure it's still sorted by price
        let sorted = sut.stocks
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(sorted[i].numericPrice, sorted[i+1].numericPrice)
        }
    }

    func test_connectionPublisher_updatesIsConnectedState() async throws {
        // Arrange
        XCTAssertFalse(sut.isConnected, "Should start disconnected until publisher emits")
        
        // Act - Simulate connected
        mockService.connectionSubject.send(true)
        try await Task.sleep(nanoseconds: 20_000_000)
        
        // Assert
        XCTAssertTrue(sut.isConnected)
        
        // Act - Simulate disconnected
        mockService.connectionSubject.send(false)
        try await Task.sleep(nanoseconds: 20_000_000)
        
        // Assert
        XCTAssertFalse(sut.isConnected)
    }
}
