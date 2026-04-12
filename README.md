# iOS Stock Tracker

A real-time iOS application that tracks stock prices. It features a completely reactive architecture bridging low-level WebSocket connections with Apple's latest `@Observable` framework and pure Swift Combine data streams.

---

## 🏗 Architecture & Components

The application adopts a layered architecture heavily emphasizing unidirectional data flow, protocol-oriented design for testability, and reactive Combine pipelines.

### 1. `EchoWebSocketClient` (Network Layer)
The lowest layer of the application responsible for the raw WebSocket lifecycle.
- **Protocol-Driven**: Conforms to `WebSocketClientProtocol`, ensuring that the rest of the application remains isolated from `URLSession` networking specifics (allowing easy local mocks for unit tests).
- **Native Implementation**: Uses `URLSessionWebSocketTask` for managing the physical TCP/WSS connection to the remote server.
- **Reactive Outputs**: Encapsulates raw delegate/closure callbacks into private `PassthroughSubject`s, exposing safe, read-only Combine `AnyPublisher` streams (`messagePublisher` and `connectionPublisher`) to upstream consumers. 

### 2. `LivePriceService` (Data & Service Layer)
The domain layer that bridges raw textual network data into strongly-typed swift models.
- **Data Transformation**: Listens to the `messagePublisher` from the WebSocket client. When it receives generic string data, it uses `JSONDecoder` to parse it into domain-specific `PriceUpdate` models.
- **Mock Simulation**: To simulate real-time market volatility safely without an expensive third-party finance API, it uses a central `Timer`. This timer randomly generates price changes for active stock symbols, formats them into a JSON payload, and sends them through the `EchoWebSocketClient` to bounce back.
- **Forwarding State**: Conforms to `LivePriceServiceProtocol`, passing the fully formatted `AnyPublisher<PriceUpdate, Never>` and connection tracking publishers directly up to the ViewModel tier.

### 3. `StockListViewModel` (Presentation Layer)
The brain of the UI, managing all visual state and responding to service-level emissions.
- **Modern Observation**: Annotated with the iOS 17 `@Observable` macro. This entirely sidesteps the older `ObservableObject` / `@Published` boilerplate, allowing SwiftUI to track properties on a granular, per-property basis automatically.
- **Combine Sinks**: Subscribes to the `priceUpdatePublisher` and `connectionPublisher` emitted by the `LivePriceService`. As updates arrive from the background over the websocket, the ViewModel sinks them directly onto the `DispatchQueue.main` to ensure safe, synchronous UI updates.
- **Logic & Formatting**: Handles user-driven logic, such as sorting. It maintains the source-of-truth list of `StockListItemViewData` mapping incoming `.symbol` updates from the live feed to specific view elements, updating `.currentPrice` and `.priceChange` directly.

## 🧪 Unit Testing & Mocking

The application is engineered with protocol-oriented design to guarantee robust isolation and maintainability across all test scenarios.

### Mocking Strategy
The testing environment relies on custom mock objects avoiding external network dependencies and allowing explicit state control during assertion:
- **`MockWebSocketClient`**: Circumvents physical networking. Instead of triggering a `URLSessionWebSocketTask`, it implements manual Combine `PassthroughSubject`s allowing the developer to exactly control when a mock string/JSON payload arrives.
- **`MockLivePriceService`**: Allows testing the `StockListViewModel` in total isolation. Ensures UI tests run deterministically by bypassing decoding logic and timers, injecting strongly-typed `PriceUpdate` models on-demand.

### Test Suites Focus
- **`StockListViewModelTests`**:
  - Focuses on UI state, confirming properties update in tandem with mocked service publisher emissions.
  - Extensively tests local list logic like maintaining descending sort operations reliably when `.price` and `.priceChange` rules are applied.
- **`LivePriceServiceTests`**:
  - Validates correct `JSONDecoder` parsing of raw text payloads into `PriceUpdate` structs.
  - Ensures that random-update `Timer` instances correctly boot and invalidate precisely when `.startTracking()` and `.stopTracking()` are invoked.
- **`EchoWebSocketClientTests`**:
  - An integration-style harness. It boots an actual connection to `wss://ws.postman-echo.com/raw`, executes a test payload, and uses `XCTestExpectation` objects to ensure the websocket properly hands the echoed message downstream into the publisher pipeline.
