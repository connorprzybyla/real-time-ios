//
//  FakeURLSession.swift
//  
//
//  Created by Connor Przybyla on 7/8/22.
//

import Foundation
@testable import real_time_ios

@available(iOS 13.0, *)
class FakeURLSession: URLSessionable {
    let fakeURLSessionWebSocketTask: URLSessionWebSocketTaskable
    
    init(fakeURLSessionWebSocketTask: URLSessionWebSocketTaskable) {
        self.fakeURLSessionWebSocketTask = fakeURLSessionWebSocketTask
    }
    
    func webSocketTaskWith(request: URLRequest) -> URLSessionWebSocketTaskable {
        fakeURLSessionWebSocketTask
    }
}
