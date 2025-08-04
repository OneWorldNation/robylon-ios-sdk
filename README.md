# iOS Chatbot SDK

A Swift Package Manager library that provides a singleton chatbot class with custom button integration and WebView-based chat interface.

## Features

- 🎯 **Singleton Pattern**: Single instance chatbot management
- 🔧 **Flexible Configuration**: Support for API key, user ID, auth token, and user profile
- 📱 **Event Handling**: Comprehensive event system for chatbot lifecycle
- 🎨 **Custom Button**: Pre-built button component with WebView integration
- 🌐 **WebView Interface**: Modern chat interface with real-time messaging
- 📊 **Event Tracking**: Track all chatbot interactions and state changes

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/iOS-sdk.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Quick Start

### 1. Initialize the Chatbot

```swift
import iOS_sdk

// Create user profile
let userProfile = UserProfile(
    name: "John Doe",
    email: "john.doe@example.com"
)

// Define event handler
let eventHandler: ChatbotEventHandler = { event in
    print("Chatbot Event: \(event.type.rawValue)")
    if let data = event.data {
        print("Event Data: \(data)")
    }
}

// Initialize chatbot
iOS_sdk.initializeChatbot(
    apiKey: "YOUR_API_KEY", // Mandatory
    userId: "optional-user-id",
    userToken: "optional-auth-token",
    userProfile: userProfile,
    eventHandler: eventHandler
)
```

### 2. Create and Use the Chatbot Button

```swift
// Create button
if let button = iOS_sdk.createChatbotButton() {
    button.setTitle("💬 Open Chatbot", for: .normal)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    
    // Add to your view
    view.addSubview(button)
    // Set up constraints...
}
```

### 3. Programmatic Control

```swift
// Open chatbot programmatically
iOS_sdk.openChatbot()

// Check if chatbot is open
let isOpen = iOS_sdk.isChatbotOpen()

// Close chatbot
iOS_sdk.closeChatbot()

// Refresh session
iOS_sdk.refreshChatbotSession()
```

## Configuration Parameters

### Required Parameters

- **`apiKey`** (String): Your chatbot API key (mandatory)

### Optional Parameters

- **`userId`** (String?): Optional user identifier
- **`userToken`** (String?): Optional authentication token
- **`userProfile`** (UserProfile?): Optional user profile information
- **`eventHandler`** (ChatbotEventHandler?): Optional event callback handler

### UserProfile Structure

```swift
let userProfile = UserProfile(
    name: "Optional User Name",
    email: "optional.email@example.com"
)
```

## Event System

The SDK provides comprehensive event tracking for all chatbot interactions:

### Event Types

```swift
public enum ChatbotEventType: String {
    case chatbotButtonLoaded = "CHATBOT_BUTTON_LOADED"
    case chatbotButtonClicked = "CHATBOT_BUTTON_CLICKED"
    case chatbotOpened = "CHATBOT_OPENED"
    case chatbotClosed = "CHATBOT_CLOSED"
    case chatbotAppReady = "CHATBOT_APP_READY"
    case chatbotLoaded = "CHATBOT_LOADED"
    case chatInitialized = "CHAT_INITIALIZED"
    case sessionRefreshed = "SESSION_REFRESHED"
    case chatInitializationFailed = "CHAT_INITIALIZATION_FAILED"
}
```

### Event Handler Example

```swift
let eventHandler: ChatbotEventHandler = { event in
    switch event.type {
    case .chatbotButtonLoaded:
        print("✅ Chatbot button loaded successfully")
    case .chatbotButtonClicked:
        print("👆 User clicked chatbot button")
    case .chatbotOpened:
        print("🚀 Chatbot opened")
    case .chatbotClosed:
        print("🔒 Chatbot closed")
    case .chatbotAppReady:
        print("🎯 Chatbot app is ready")
    case .chatbotLoaded:
        print("📱 Chatbot loaded in WebView")
    case .chatInitialized:
        print("✅ Chatbot initialized successfully")
    case .sessionRefreshed:
        print("🔄 Session refreshed")
    case .chatInitializationFailed:
        print("❌ Chatbot initialization failed")
        if let error = event.data?["error"] as? String {
            print("   Error: \(error)")
        }
    }
}
```

## Complete Example

```swift
import UIKit
import iOS_sdk

class ViewController: UIViewController {
    
    private var chatbotButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatbot()
        setupUI()
    }
    
    private func setupChatbot() {
        let userProfile = UserProfile(
            name: "Example User",
            email: "user@example.com"
        )
        
        iOS_sdk.initializeChatbot(
            apiKey: "YOUR_API_KEY",
            userId: "user123",
            userToken: "auth_token_123",
            userProfile: userProfile
        ) { event in
            // Handle all chatbot events
            print("📱 Event: \(event.type.rawValue)")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Create and configure chatbot button
        chatbotButton = iOS_sdk.createChatbotButton()
        
        if let button = chatbotButton {
            button.setTitle("💬 Open Chatbot", for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
}
```

## Architecture

The SDK is built using a singleton pattern with the following components:

- **`Chatbot`**: Main singleton class managing chatbot state and lifecycle
- **`ChatbotConfiguration`**: Configuration structure for initialization
- **`ChatbotEvent`**: Event structure with type, timestamp, and optional data
- **`UserProfile`**: User information structure
- **`WebViewController`**: WebView-based chat interface
- **`CustomButton`**: Pre-built button component

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 12.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on GitHub or contact the development team. 