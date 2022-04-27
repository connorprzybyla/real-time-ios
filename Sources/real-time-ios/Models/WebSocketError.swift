
import Foundation

public enum WebSocketError: Error {
    case disconnected
    case generic
    case fatal(Error)
}

extension WebSocketError: Equatable {
    public static func == (lhs: WebSocketError, rhs: WebSocketError) -> Bool {
        switch (lhs, rhs) {
        case (.generic, .generic),
             (.disconnected, .disconnected),
             (.fatal, .fatal):
            return true
        default:
            return false
        }
    }
}
