import Foundation
import KituraWebSocket
import XCTest
import NIO
import NIOWebSocket
import NIOHTTP1
@testable import WebSocketClient

class ComplexTests: WebSocketClientTests {

    func testBinaryShortAndMediumFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e]
        var mediumBinaryPayload = bytes
        repeat {
            mediumBinaryPayload.append(contentsOf: mediumBinaryPayload)
        } while mediumBinaryPayload.count < 1000

        var expectedFrame = bytes
        expectedFrame.append(contentsOf: mediumBinaryPayload)
        performServerTest(asyncTasks: { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: false)
            client.sendBinary(Data(mediumBinaryPayload), opcode: .continuation, finalFrame: true, compressed: false)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: false)
            client.sendBinary(Data(mediumBinaryPayload), opcode: .continuation, finalFrame: true, compressed: false)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: true)
            client.sendBinary(Data(mediumBinaryPayload), opcode: .continuation, finalFrame: true, compressed: true)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()

            }
        })
    }

    func testTwoBinaryShortFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e]
        var expectedFrame = bytes
        expectedFrame.append(contentsOf: bytes)
        performServerTest(asyncTasks: { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: false)
            client.sendBinary(Data(bytes), opcode: .continuation, finalFrame: true, compressed: false)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: false)
            client.sendBinary(Data(bytes), opcode: .continuation, finalFrame: true, compressed: false)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendBinary(Data(bytes), opcode: .binary, finalFrame: false, compressed: true)
            client.sendBinary(Data(bytes), opcode: .continuation, finalFrame: true, compressed: true)
            client.onBinary{ receivedData in
                XCTAssertEqual(receivedData, Data(expectedFrame), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedFrame)).")
                expectation.fulfill()

            }
        })
    }

    func testPingBetweenBinaryFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest { expectation in
            let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e]
            var expectedBinaryPayload = bytes
            expectedBinaryPayload.append(contentsOf: bytes)
            let pingPayload = "Testing, testing 1,2,3"
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.onBinary { receivedData in
                XCTAssertEqual(receivedData, Data(expectedBinaryPayload), "The payload recieved \(receivedData) is not equal to expected payload \(Data(expectedBinaryPayload)).")
                expectation.fulfill()
            }
            client.onPong { opcode, data in
                XCTAssertEqual(opcode, WebSocketOpcode.pong, "Recieved opcode \(opcode) is not equal expected opcode \(WebSocketOpcode.pong).")
                let recievedPayload =  String(data: data, encoding: .utf8)
                XCTAssertEqual(recievedPayload, pingPayload, "Recieved opcode \(recievedPayload) is not equal expected opcode \(pingPayload).")
            }

            client.connect()
            client.sendBinary(Data(bytes), finalFrame: false)
            client.ping(data: pingPayload.data(using: .utf8)!)
            client.sendBinary(Data(bytes), opcode: .continuation,finalFrame: true)
        }
    }

    func testPingBetweenTextFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest { expectation in
            let text = "Testing, testing 1, 2, 3. "
            let pingPayload = "Testing, testing 1,2,3"
            var expectedPayload = text
            expectedPayload.append(contentsOf: text)
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.onText { receivedData in
                XCTAssertEqual(expectedPayload, receivedData, "The payload recieved \(receivedData) is not equal to expected payload \(expectedPayload).")
                expectation.fulfill()
            }
            client.onPong { opcode, data in
                XCTAssertEqual(opcode, WebSocketOpcode.pong, "Recieved opcode \(opcode) is not equal expected opcode \(WebSocketOpcode.pong).")
                let recievedPayload =  String(data: data, encoding: .utf8)
                XCTAssertEqual(recievedPayload, pingPayload, "Recieved opcode \(recievedPayload) is not equal expected opcode \(pingPayload).")
            }

            client.connect()
            client.sendText(text, finalFrame: false)
            client.ping(data: pingPayload.data(using: .utf8)!)
            client.sendText(text, opcode: .continuation,finalFrame: true)
        }
    }

    func testTextShortAndMediumFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        let shortText = "Testing, testing 1, 2, 3. "
        var mediumText = ""
        repeat {
            mediumText += "Testing, testing 1,2,3. "
        } while mediumText.count < 1000
        var textExpectedPayload = shortText
        textExpectedPayload.append(contentsOf: mediumText)
        performServerTest(asyncTasks: { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false)
            client.sendText(mediumText, opcode: .continuation, finalFrame: true, compressed: false)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false)
            client.sendText(mediumText, opcode: .continuation, finalFrame: true, compressed: false)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false, compressed: true)
            client.sendText(mediumText, opcode: .continuation, finalFrame: true, compressed: true)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        })
    }

    func testTextTwoShortFrames() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        let shortText = "Testing, testing 1, 2, 3. "
        var textExpectedPayload = shortText
        textExpectedPayload.append(contentsOf: shortText)
        performServerTest(asyncTasks: { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester") else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false)
            client.sendText(shortText, opcode: .continuation, finalFrame: true, compressed: false)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false)
            client.sendText(shortText, opcode: .continuation, finalFrame: true, compressed: false)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        }, { expectation in
            guard let client = WebSocketClient("http://localhost:8080/wstester", config: CompressionConfig()) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(shortText, finalFrame: false, compressed: true)
            client.sendText(shortText, opcode: .continuation, finalFrame: true, compressed: true)
            client.onText{ receivedData in
                XCTAssertEqual(receivedData, textExpectedPayload, "The payload recieved \(receivedData) is not equal to expected payload \(textExpectedPayload).")
                expectation.fulfill()
            }
        })
    }

    func testTwoMessages(contextTakeover: ContextTakeover = .both) {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        let text = "RFC7692 specifies a framework for adding compression functionality to the WebSocket Protocol"
        performServerTest { expectation in
            var count = 0
            guard let client = WebSocketClient("http://localhost:8080/wstester", config:  CompressionConfig(contextTakeover: contextTakeover)) else {
                XCTFail("Unable to create client")
                return
            }
            client.connect()
            client.sendText(text)
            client.sendText(text)
            client.onText { receivedData in
                count += 1
                XCTAssertEqual(receivedData, text, "The payload recieved \(receivedData) is not equal to expected payload \(text).")
                if count == 2 {
                    expectation.fulfill()
                }
            }
        }
    }

    func testTwoMessagesWithContextTakeover() {
        testTwoMessages(contextTakeover: .both)
    }

    func testTwoMessagesWithClientContextTakeover() {
        testTwoMessages(contextTakeover: .client)
    }

    func testTwoMessagesWithServerContextTakeover() {
        testTwoMessages(contextTakeover: .server)
    }

    func testTwoMessagesWithNoContextTakeover() {
        testTwoMessages(contextTakeover: .none)
    }
}
