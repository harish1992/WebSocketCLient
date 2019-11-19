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
}
