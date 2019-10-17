import XCTest
import KituraWebSocket
@testable import WebSocketClient

final class WebSocketClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let client = WebSocketClient(host: "localhost", port: 8080, uri: "/", requestKey: "test")
    }

    
    static var allTests = [
        ("testExample", testExample),
    ]
}