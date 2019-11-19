//
//  basictests.swift
//  WebSocketClient
//
//  Created by Haris Kumar S on 13/11/19.
//

import Foundation
import KituraWebSocket
import XCTest
@testable import WebSocketClient

class BasicTests: WebSocketClientTests {

    func testTextMessage() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest{ expectation in
            let textToSend = "Hi"
            let client = WebSocketClient(host: "localhost", port: 8080,
                                         uri: self.servicePath, requestKey: "test")
            client?.onText({ text in
                print(text, "Text recieved")
                XCTAssertEqual(text, textToSend, "\(text) not equal to \(textToSend)")
                expectation.fulfill()
            })
            client?.connect()
            client?.sendText(textToSend)
        }
    }

    func testDataMessage() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest{ expectation in
            let dataToSend = Data.init([99,100])
            let client = WebSocketClient(host: "localhost", port: 8080,
                                         uri: self.servicePath, requestKey: "test")
            client?.onBinary({ (data) in
                XCTAssertEqual(data, dataToSend, "\(data) not equal to \(dataToSend)")
                expectation.fulfill()
            })
            client?.connect()
            client?.sendBinary(dataToSend)
        }
    }

    func testClientInitWithURL() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest{ expectation in
            let dataToSend = Data.init([99,100])
            let client = WebSocketClient("http://localhost:8080/wstester")
            client?.onBinary({ (data) in
                XCTAssertEqual(data, dataToSend, "\(data) not equal to \(dataToSend)")
                expectation.fulfill()
            })
            client?.connect()
            client?.sendBinary(dataToSend)
        }
    }
}
