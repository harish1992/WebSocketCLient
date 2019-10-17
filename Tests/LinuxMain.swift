import XCTest

import WebSocketClientTests

var tests = [XCTestCaseEntry]()
tests += WebSocketClientTests.allTests()
XCTMain(tests)
