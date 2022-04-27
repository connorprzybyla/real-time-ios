//
//  WebSocketManagerTests.swift
//  real-time-ios
//
//  Created by Connor Przybyla on 4/26/22.
//

import Foundation
import XCTest

@testable import real_time_ios

class WebSocketManagerTests: XCTestCase {
    func testWebSocketManagerInitialization() {
        let sut = WebSocketManager(urlRequest: URLRequest(url: URL(string: "wss://socket.api/v1")!))
        XCTAssertNotNil(sut)
    }
}
