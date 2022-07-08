//
//  WebSocketManager.swift
//  real-time-ios
//
//  Created by Connor Przybyla on 4/7/22.
//

import Combine
import Foundation

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(macOS 10.15, *)
protocol WebSocketManageable {
    associatedtype WebSocketMessage: Decodable
    func connect()
    func send(message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error?) -> Void))
    func receive() -> AnyPublisher<WebSocketMessage, WebSocketError>
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(macOS 10.15, *)
public final class WebSocketManager<T: Decodable>: NSObject, URLSessionWebSocketDelegate, WebSocketManageable {
    typealias WebSocketMessage = T
    
    private let urlRequest: URLRequest
    private var urlSession: URLSessionable
    private var webSocketTask: URLSessionWebSocketTaskable?
    private let messageSubject = PassthroughSubject<WebSocketMessage, WebSocketError>()
    
    public init(urlRequest: URLRequest,
                urlSession: URLSessionable) {
        self.urlRequest = urlRequest
        self.urlSession = urlSession
        super.init()
    }
    
    public func connect() {
        webSocketTask = urlSession.webSocketTaskWith(request: urlRequest)
        webSocketTask?.resume()
        setupWebSocketTaskReceive()
    }
    
    public func receive() -> AnyPublisher<T, WebSocketError> {
        messageSubject.eraseToAnyPublisher()
    }
    
    public func send(message: URLSessionWebSocketTask.Message,
                     completionHandler: @escaping ((Error?) -> Void)) {
        webSocketTask?.send(message, completionHandler: { error in
            completionHandler(error)
        })
    }
    
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode,
                           reason: Data?) {
        webSocketTask?.cancel(with: closeCode, reason: reason)
    }
    
    private func setupWebSocketTaskReceive() {
        urlSession.webSocketTaskWith(request: urlRequest)
            .receive { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        guard let webSocketMessage = Self.decodeWebSocketMessage(with: data) else { return }
                        self.messageSubject.send(webSocketMessage)
                    default:
                        return
                    }
                    
                case .failure(let error):
                    self.messageSubject.send(completion: .failure(WebSocketError.fatal(error)))
                }
                
                self.setupWebSocketTaskReceive()
            }
    }
    
    private static func decodeWebSocketMessage(with data: Data) -> WebSocketMessage? {
          guard let webSocketMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) else { return nil }

          return webSocketMessage
      }
}
