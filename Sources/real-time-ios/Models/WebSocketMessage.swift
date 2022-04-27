//
//  WebSocketMessage.swift
//  real-time-ios
//
//  Created by Connor Przybyla on 4/8/22.
//
import Foundation

public struct WebSocketMessage: Decodable, Equatable {
    var data: Data?
    var socketStatus: Int
    var timeUTC: String
}
