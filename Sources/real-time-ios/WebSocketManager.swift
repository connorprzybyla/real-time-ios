//
//  WebSocketManager.swift
//  real-time-ios
//
//  Created by Connor Przybyla on 4/7/22.
//

import Combine
import Foundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public protocol WebSocketManageable {
    func connect()
    func receive() -> AnyPublisher<WebSocketMessage, WebSocketError>
    func disconnect()
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class WebSocketManager: NSObject, URLSessionWebSocketDelegate, WebSocketManageable {
    
    private let urlRequest: URLRequest
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    private let messageSubject = PassthroughSubject<WebSocketMessage, WebSocketError>()
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init()
        configureURLSession()
    }
    
    public func connect() {
        webSocketTask?.resume()
        configureWebSocketTaskReceive()
    }
    
    public func receive() -> AnyPublisher<WebSocketMessage, WebSocketError> {
        messageSubject.eraseToAnyPublisher()
    }
    
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    // MARK: Private
    
    private func configureURLSession() {
        let delegateQueue = OperationQueue()
        delegateQueue.qualityOfService = .utility
        
        urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: delegateQueue
        )
        webSocketTask = urlSession?.webSocketTask(with: urlRequest)
    }
    
    private func configureWebSocketTaskReceive() {
        urlSession?.webSocketTask(with: urlRequest)
            .receive { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        guard let webSocketMessage = self.decodeWebSocketMessage(with: data) else { return }
                        self.messageSubject.send(webSocketMessage)
                    default:
                        return
                    }
                    
                case .failure(let error):
                    self.messageSubject.send(completion: .failure(WebSocketError.fatal(error)))
                }
                self.configureWebSocketTaskReceive()
            }
    }
    
    private func decodeWebSocketMessage(with data: Data) -> WebSocketMessage? {
        guard let webSocketMessage = try? JSONDecoder().decode(WebSocketMessage.self,
                                                               from: data) else { return nil }
        return webSocketMessage
    }
}
