//
//  URLSessionable.swift
//  
//
//  Created by Connor Przybyla on 5/2/22.
//

import Foundation

@available(iOS 13.0, *)
public protocol URLSessionable {
    func webSocketTaskWith(request: URLRequest) -> URLSessionWebSocketTaskable
}

@available(iOS 13.0, *)
public protocol URLSessionWebSocketTaskable {
    var  delegate: URLSessionTaskDelegate? { get set }
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void))
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

@available(iOS 13.0, *)
extension URLSession: URLSessionable {
    public func webSocketTaskWith(request: URLRequest) -> URLSessionWebSocketTaskable {
        webSocketTask(with: request)
    }
}

@available(iOS 13.0, *)
extension URLSessionWebSocketTask: URLSessionWebSocketTaskable {}
