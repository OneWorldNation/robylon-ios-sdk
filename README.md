# Robylon iOS Chatbot SDK

A Swift Package Manager library that provides a singleton chatbot class with custom button integration and WebView-based chat interface. The SDK supports both staging and production environments with comprehensive event tracking and analytics.

## Features

- 🎯 **Singleton Pattern**: Single instance chatbot management
- 🔧 **Flexible Configuration**: Support for API key, user ID, auth token, and user profile
- 📱 **Event Handling**: Comprehensive event system for chatbot lifecycle
- 🎨 **Custom Button**: Pre-built button component with WebView integration
- 🌐 **WebView Interface**: Modern chat interface with real-time messaging
- 📊 **Event Tracking**: Track all chatbot interactions and state changes
- 🔄 **Environment Support**: Debug mode for staging, production mode for live apps
- 🎭 **Presentation Styles**: Support for default and fullscreen presentation modes
- 🖼️ **Dynamic Button Styling**: Button appearance driven by API response
- 📈 **Analytics Integration**: Automatic event tracking and logging

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/OneWorldNation/robylon-ios-sdk", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Quick Start

### 1. Initialize the Chatbot

```swift
import RobylonSDK

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

// Create configuration
let config = ChatbotConfiguration(
    apiKey: "YOUR_API_KEY", // Mandatory
    userId: "optional-user-id",
    userToken: "optional-auth-token",
    userProfile: userProfile,
    eventHandler: eventHandler,
    parentView: self.view, // UIView where button will be added
    debugMode: false, // Set to true for staging environment
    presentationStyle: .default // or .fullscreen. This denotes how the chatbot will open.
)


// Initialize chatbot
RobylonSDK.initializeChatbot(config: config)
```

### 2. Automatic Button Creation

The SDK automatically creates and adds a custom button to the specified parent view. The button's appearance is dynamically configured based on the API response:

- **Text Only**: Button with custom text and styling
- **Image Only**: Circular button with custom image
- **Text + Image**: Button with text and circular image

## Configuration Parameters

### Required Parameters

- **`apiKey`** (String): Your chatbot API key (mandatory)

### Optional Parameters

- **`orgId`** (String?): Optional organization ID for multi-tenancy
- **`userId`** (String?): Optional user identifier (auto-generated UUID if not provided)
- **`userToken`** (String?): Optional authentication token
- **`userProfile`** (UserProfile?): Optional user profile information
- **`debugMode`** (Bool): Set to `true` for staging environment, `false` for production (default: `false`)
- **`eventHandler`** (ChatbotEventHandler?): Optional event callback handler
- **`parentView`** (UIView?): UIView where the chatbot button will be added
- **`presentationStyle`** (ChatBotPresentationStyle): How the chatbot interface should be presented (default: `.default`)

### UserProfile Structure

```swift
let userProfile = UserProfile(
    name: "Optional User Name",
    email: "optional.email@example.com"
)
```

### Presentation Styles

```swift
public enum ChatBotPresentationStyle {
    case `default`    // Automatic presentation style
    case fullscreen   // Full screen presentation
}
```

## Environment Configuration

The SDK supports two environments controlled by the `debugMode` parameter:

### Debug Mode (Staging)
```swift
let config = ChatbotConfiguration(
    apiKey: "your-api-key",
    debugMode: true, // Uses staging API
    // ... other parameters
)
```
- **Use Case**: Development and testing

### Production Mode
```swift
let config = ChatbotConfiguration(
    apiKey: "your-api-key",
    debugMode: false, // Uses production API
    // ... other parameters
)
```
- **Use Case**: Live applications

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
import RobylonSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatbot()
    }
    
    private func setupChatbot() {
        let userProfile = UserProfile(
            name: "Example User",
            email: "user@example.com"
        )
        
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            userId: "user123",
            userToken: "auth_token_123",
            userProfile: userProfile,
            debugMode: true, // Use staging for development
            eventHandler: { event in
                // Handle all chatbot events
                print("📱 Event: \(event.type.rawValue)")
                
                switch event.type {
                case .chatbotButtonLoaded:
                    print("✅ Button loaded and ready")
                case .chatbotOpened:
                    print("🚀 Chatbot interface opened")
                case .chatbotClosed:
                    print("🔒 Chatbot interface closed")
                case .chatInitializationFailed:
                    if let error = event.data?["error"] as? String {
                        print("❌ Initialization failed: \(error)")
                    }
                default:
                    break
                }
            },
            parentView: self.view, // Button will be added to this view
            presentationStyle: .default
        )
        
        RobylonSDK.initializeChatbot(config: config)
    }
}
```

## SwiftUI Integration

For SwiftUI apps, you can use the `ParentViewProvider` to get a UIView reference:

```swift
import SwiftUI
import RobylonSDK

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to the App")
            // Other SwiftUI content
        }
        .background(
            ParentViewProvider { parentView in
                // Initialize chatbot with the parent view
                let config = ChatbotConfiguration(
                    apiKey: "YOUR_API_KEY",
                    debugMode: true,
                    eventHandler: { event in
                        print("Event: \(event.type.rawValue)")
                    },
                    parentView: parentView
                )
                RobylonSDK.initializeChatbot(config: config)
            }
        )
    }
}
// MARK: - Parent View Provider
struct ParentViewProvider: UIViewRepresentable {
    let onViewReady: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Call the closure when the view is ready
        DispatchQueue.main.async {
            onViewReady(uiView)
        }
    }
}
```

## UIKit Integration

For UIKit apps, you can integrate the chatbot directly in your view controller:

```swift
import UIKit
import RobylonSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChatbot()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add your app's UI elements here
        let titleLabel = UILabel()
        titleLabel.text = "Welcome to the App"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupChatbot() {
        let userProfile = UserProfile(
            name: "UIKit User",
            email: "user@example.com"
        )
        
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            userId: "uikit-user-123",
            userToken: "auth-token-123",
            userProfile: userProfile,
            debugMode: true, // Use staging for development
            eventHandler: { [weak self] event in
                // Handle all chatbot events
                print("📱 Event: \(event.type.rawValue)")
                
                switch event.type {
                case .chatbotButtonLoaded:
                    print("✅ Chatbot button loaded successfully")
                    // You can perform UI updates here if needed
                    DispatchQueue.main.async {
                        self?.handleButtonLoaded()
                    }
                    
                case .chatbotButtonClicked:
                    print("👆 User clicked chatbot button")
                    
                case .chatbotOpened:
                    print("🚀 Chatbot interface opened")
                    
                case .chatbotClosed:
                    print("🔒 Chatbot interface closed")
                    
                case .chatInitialized:
                    print("✅ Chatbot initialized successfully")
                    
                case .chatInitializationFailed:
                    print("❌ Chatbot initialization failed")
                    if let error = event.data?["error"] as? String {
                        print("   Error: \(error)")
                        // Show error alert to user
                        DispatchQueue.main.async {
                            self?.showErrorAlert(message: error)
                        }
                    }
                    
                case .sessionRefreshed:
                    print("🔄 Session refreshed")
                    
                default:
                    break
                }
            },
            parentView: self.view, // Button will be added to this view controller's view
            presentationStyle: .default // or .fullscreen for full screen presentation
        )
        
        RobylonSDK.initializeChatbot(config: config)
    }
    
    // MARK: - Helper Methods
    
    private func handleButtonLoaded() {
        // Perform any UI updates when button is loaded
        print("Chatbot button is ready for interaction")
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Chatbot Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

### UIKit Integration with Tab Bar Controller

For apps with tab bar controllers, you can add the chatbot to a specific tab:

```swift
import UIKit
import RobylonSDK

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupChatbot()
    }
    
    private func setupTabs() {
        let firstVC = UIViewController()
        firstVC.view.backgroundColor = .systemBackground
        firstVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let secondVC = UIViewController()
        secondVC.view.backgroundColor = .systemBackground
        secondVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        viewControllers = [firstVC, secondVC]
    }
    
    private func setupChatbot() {
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            debugMode: true,
            eventHandler: { event in
                print("Chatbot Event: \(event.type.rawValue)")
            },
            parentView: view, // Add to the tab bar controller's view
            presentationStyle: .default
        )
        
        RobylonSDK.initializeChatbot(config: config)
    }
}
```

## Architecture

The SDK is built using a singleton pattern with the following components:

### Core Components
- **`RobylonSDK`**: Main public interface for SDK initialization
- **`Chatbot`**: Singleton class managing chatbot state and lifecycle

## Memory Management

The SDK implements proper memory management:

- **Singleton Pattern**: Single instance prevents memory leaks
- **Weak References**: Prevents retain cycles in closures
- **Automatic Cleanup**: WebView resources are properly cleaned up
- **Listener Management**: JavaScript listeners are added/removed appropriately

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on GitHub or contact the development team.
