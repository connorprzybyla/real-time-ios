//
//  WebSocketMessage.swift
//  
//
//  Created by Connor Przybyla on 6/23/22.
//

import Foundation

public struct WebSocketMessage: Decodable, Equatable {
    var data: String
    var socketStatus: Int
    var timeUTC: String
}
