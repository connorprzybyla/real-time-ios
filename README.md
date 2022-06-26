## real-time-ios

A lightweight, testable, and scalable Swift package for all your WebSocket needs.

This package is open-sourced and built to support devices across Apple's ecosystem including iOS, iPadOS, watchOS, tvOS, and macOS.


Setup: 

First, you'll need to add this package to your Xcode project. See Apple's official docs if you don't already know how to. [view them here](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)


## How to use WebSocketManager

- Step 1.) Create an instance of WebSocketManager. WebSocketManager is a generic class that requires a decode type. This type is the model you want to use for message decoding.

 
 Example of a websocket message for real-time stock information
 
{
  "stocks": [
    {
      "name": "Apple Inc.",
      "sym": "AAPL",
      "price": 141.66
    },
    {
      "name": "Snap Inc.",
      "sym": "SNAP",
      "price": 14.7
    },
    {
      "name": "Meta Platforms, Inc.",
      "sym": "META",
      "price": 170.16
    },
    {
      "name": "Alphabet Inc.",
      "sym": "GOOG",
      "price": 2370.79
    }
  ]
}

Your decodable model should look like:
    
struct WebSocketMessage: Decodable {
    var stocks: [Stock]
    
    stuct Stock: Decodable {
        var name: String
        var sym: String
        var price: Double 
    }
}

Now, with your newly created WebSocketManager, you can subscribe to the receive publisher. You will now receive values over time.


Receiving messages:

var subscriptions = Set<AnyCancellables>()
let webSocketManager = WebSocketManager()

webSocketManager
    .receive()
    .sink(receiveValue: { webSocketMessage in
        // handle your messages here
    }, receiveCompletion: { completion in
        // handle completion here
    }.store(in: &subscriptions)
