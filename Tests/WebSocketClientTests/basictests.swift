//
//  basictests.swift
//  WebSocketClient
//
//  Created by Haris Kumar S on 13/11/19.
//

import Foundation
import KituraWebSocket
@testable import WebSocketClient

class BasicTests: WebSocketClientTests {
    
    func testBinaryLongMessage() {
        let echoDelegate = EchoService()
        WebSocket.register(service: echoDelegate, onPath: self.servicePath)
        performServerTest{ expectation in
            let delegate: WSDelegate = WSDelegate()
            let client = WebSocketClient(host: "localhost", port: 8080,
                                         uri: self.servicePath, requestKey: "test")
            client?.delegate = delegate
            client?.connect()
            client?.sendText("Hi")
        }
    }
}

class WSDelegate: WebSocketClientDelegate {
    func onText(text: String) {
        print(text,"Text in delegate")
    }
}
