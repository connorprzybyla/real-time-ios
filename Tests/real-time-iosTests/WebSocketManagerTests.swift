//
//  WebSocketManagerTests.swift
//  real-time-ios
//
//  Created by Connor Przybyla on 4/26/22.
//

import Combine
import XCTest

@testable import real_time_ios



@available(iOS 13.0, *)
class WebSocketManagerTests: XCTestCase {
    func testWebSocketManagerConnectCallsWebSocketTaskResume() {
        let fakeURLSessionWebSocketTask = FakeURLSessionWebSocketTask()
        let fakeURLSession = FakeURLSession(fakeURLSessionWebSocketTask: fakeURLSessionWebSocketTask)
        let sut = WebSocketManager<WebSocketMessage>(urlRequest: URLRequest(url: URL(string: "wss://socket.api/v1")!),
                                   urlSession: fakeURLSession)
        
        sut.connect()
        
        XCTAssertTrue(fakeURLSessionWebSocketTask.didCallResume)
    }
    
    func testWebSocketManagerDisconnectCallsWebSocketTaskCancel() {
        let fakeURLSessionWebSocketTask = FakeURLSessionWebSocketTask()
        let fakeURLSession = FakeURLSession(fakeURLSessionWebSocketTask: fakeURLSessionWebSocketTask)
        let sut = WebSocketManager<WebSocketMessage>(urlRequest: URLRequest(url: URL(string: "wss://socket.api/v1")!),
                                   urlSession: fakeURLSession)
        sut.connect()
        sut.disconnect(with: .goingAway, reason: nil)
        
        XCTAssertTrue(fakeURLSessionWebSocketTask.didCallCancel)
    }
    
    func testWebSocketManagerSendIsSuccessful() {
        let fakeURLSessionWebSocketTask = FakeURLSessionWebSocketTask()
        let fakeURLSession = FakeURLSession(fakeURLSessionWebSocketTask: fakeURLSessionWebSocketTask)
        let sut = WebSocketManager<WebSocketMessage>(urlRequest: URLRequest(url: URL(string: "wss://socket.api/v1")!),
                                   urlSession: fakeURLSession)
        sut.connect()
        
        var receivedError: Error?
        sut.send(message: .string("Are you there?")) { error in
            guard let error = error else { return }
            receivedError = error
        }
        
        let expectedSendMessageSpy: URLSessionWebSocketTask.Message = .string("Are you there?")
        XCTAssertEqual(expectedSendMessageSpy, fakeURLSessionWebSocketTask.sendMessageSpy)
        XCTAssertNil(receivedError)
    }
    
    func testWebSocketManagerReceiveIsSuccessful() {
        let expectation = XCTestExpectation()
        var subscriptions = Set<AnyCancellable>()
        let fakeURLSessionWebSocketTask = FakeURLSessionWebSocketTask()
        let jsonObject: [String: Any] = [
            "data": "Apple",
            "socketStatus": 999.99,
            "timeUTC": "06/08/2022 12:00"
        ]
        fakeURLSessionWebSocketTask.receiveTestResult = .success(.data(WebSocketManagerTests.jsonToData(json: jsonObject)!))
        let fakeURLSession = FakeURLSession(fakeURLSessionWebSocketTask: fakeURLSessionWebSocketTask)
        let sut = WebSocketManager<WebSocketMessage>(
            urlRequest: URLRequest(url: URL(string: "wss://socket.api/v1")!),
            urlSession: fakeURLSession
        )
        sut.connect()
        var receivedWebSocketMessage: WebSocketMessage?
        sut.receive()
            .sink { _ in } receiveValue: { webSocketMessage in
                receivedWebSocketMessage = webSocketMessage
                expectation.fulfill()
            }.store(in: &subscriptions)
        
        
        fakeURLSessionWebSocketTask.completionHandler = .success(.data(WebSocketManagerTests.jsonToData(json: jsonObject)!))
        wait(for: [expectation], timeout: 1.0)
        let expectedWebSocketMessage = WebSocketManagerTests.decodeWebSocketMessage(with: WebSocketManagerTests.jsonToData(json: jsonObject))
        XCTAssertEqual(expectedWebSocketMessage, receivedWebSocketMessage)
    }
}

@available(iOS 13.0, *)
extension WebSocketManagerTests {
    static func jsonToData(json: Any) -> Data? {
        do {
            return try JSONSerialization.data(
                withJSONObject: json,
                options: JSONSerialization.WritingOptions.prettyPrinted
            )
        } catch let error {
            print("jsonToData failed with \(error)")
        }
        return nil
    }
    
    static func decodeWebSocketMessage(with data: Data?) -> WebSocketMessage? {
        guard let data = data else { return nil }
        guard let webSocketMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) else { return nil }
        
        return webSocketMessage
    }
}

// MARK: - URLSessionWebSocketTask.Message + Equatable

@available(iOS 13.0, *)
extension URLSessionWebSocketTask.Message: Equatable {
    public static func == (lhs: URLSessionWebSocketTask.Message, rhs: URLSessionWebSocketTask.Message) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsString), .string(let rhsString)):
            return lhsString == rhsString
        case (.data(let lhsData), .data(let rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}
