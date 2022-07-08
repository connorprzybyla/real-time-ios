//
//  FakeURLSessionWebSocketTask.swift
//  
//
//  Created by Connor Przybyla on 7/8/22.
//

import Foundation
@testable import real_time_ios

@available(iOS 13.0, *)
class FakeURLSessionWebSocketTask: URLSessionWebSocketTaskable {
    
    var sendMessageSpy: URLSessionWebSocketTask.Message?
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void)) {
        sendMessageSpy = message
        completionHandler(nil)
    }
    
    var receiveTestResult: Result<URLSessionWebSocketTask.Message, Error> = Result.success(.data(WebSocketManagerTests.jsonToData(json: [
        "data": "Apple",
        "socketStatus": 999.99,
        "timeUTC": "06/08/2022 12:00"
    ])!))
    
    var completionHandler: (Result<URLSessionWebSocketTask.Message, Error>)?
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        completionHandler(receiveTestResult)
    }
    
    var didCallResume = false
    func resume() {
        didCallResume = true
    }
    
    var didCallCancel = false
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCallCancel = true
    }
}
