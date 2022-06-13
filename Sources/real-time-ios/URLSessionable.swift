//
//  URLSessionable.swift
//  
//
//  Created by Connor Przybyla on 5/2/22.
//

import Foundation

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
public protocol URLSessionable {
    func webSocketTaskWith(request: URLRequest) -> URLSessionWebSocketTaskable
}

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
public protocol URLSessionWebSocketTaskable {
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void))
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension URLSession: URLSessionable {
    public func webSocketTaskWith(request: URLRequest) -> URLSessionWebSocketTaskable {
        webSocketTask(with: request)
    }
}

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension URLSessionWebSocketTask: URLSessionWebSocketTaskable {}
