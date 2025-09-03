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
    .package(url: "https://github.com/OneWorldNation/robylon-ios-sdk", from: "1.0.3")
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

### 3. Opening Chatbot Directly (Without automatic Button)

If you already have a custom button and want to open the chatbot directly without the automatic button creation, you can use the direct opening method:

```swift
// Open chatbot directly with configuration
// This will automatically initialize if needed and open the chatbot
RobylonSDK.openChatbot(config: config)
```

**Key Benefits:**
- **Automatic Initialization**: If the chatbot isn't initialized, it will initialize automatically
- **No Button Required**: Perfect for apps with custom UI or existing buttons
- **Seamless Experience**: Handles initialization and opening in one call
- **KVO-Based**: Uses Key-Value Observing for real-time initialization status updates

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

### Basic Integration with Automatic Button

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

### SwiftUI with Custom Button and Direct Opening

If you want to use your own custom button in SwiftUI and open the chatbot directly:

```swift
import SwiftUI
import RobylonSDK

struct ContentView: View {
    @State private var chatbotConfig: ChatbotConfiguration?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to the App")
                .font(.title)
                .fontWeight(.bold)
            
            // Custom chatbot button
            Button(action: {
                openChatbot()
            }) {
                HStack {
                    Image(systemName: "message.circle.fill")
                        .foregroundColor(.white)
                    Text("Chat with Support")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(25)
            }
            
            // Other SwiftUI content
            Text("Your app content goes here...")
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            setupChatbot()
        }
    }
    
    private func setupChatbot() {
        // Create configuration without parentView (no automatic button)
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            userId: "swiftui-user-123",
            userProfile: UserProfile(
                name: "SwiftUI User",
                email: "user@example.com"
            ),
            debugMode: true,
            eventHandler: { event in
                print("📱 SwiftUI Event: \(event.type.rawValue)")
                
                switch event.type {
                case .chatbotOpened:
                    print("🚀 Chatbot opened from SwiftUI")
                case .chatbotClosed:
                    print("🔒 Chatbot closed from SwiftUI")
                case .chatInitializationFailed:
                    if let error = event.data?["error"] as? String {
                        print("❌ Error: \(error)")
                    }
                default:
                    break
                }
            },
            parentView: nil, // No automatic button
            presentationStyle: .default
        )
        
        self.chatbotConfig = config
    }
    
    private func openChatbot() {
        guard let config = chatbotConfig else {
            print("Chatbot not configured")
            return
        }
        
        // Open chatbot directly - will initialize if needed
        RobylonSDK.openChatbot(config: config)
    }
}
```

### SwiftUI with Multiple Chatbot Triggers

For apps that need to open the chatbot from different places:

```swift
import SwiftUI
import RobylonSDK

struct ChatbotManager: ObservableObject {
    private var config: ChatbotConfiguration?
    
    init() {
        setupChatbot()
    }
    
    private func setupChatbot() {
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            debugMode: true,
            eventHandler: { event in
                print("Event: \(event.type.rawValue)")
            },
            parentView: nil
        )
        self.config = config
    }
    
    func openChatbot() {
        guard let config = config else { return }
        RobylonSDK.openChatbot(config: config)
    }
}

struct ContentView: View {
    @StateObject private var chatbotManager = ChatbotManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main Content")
                    .font(.title)
                
                // Chat button in main content
                Button("Open Chat") {
                    chatbotManager.openChatbot()
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink("Settings") {
                    SettingsView(chatbotManager: chatbotManager)
                }
            }
            .padding()
            .navigationTitle("App")
        }
    }
}

struct SettingsView: View {
    let chatbotManager: ChatbotManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
            
            // Chat button in settings
            Button("Get Help") {
                chatbotManager.openChatbot()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Settings")
    }
}
```

## UIKit Integration

### Basic Integration with Automatic Button

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

### UIKit with Custom Button and Direct Opening

If you want to use your own custom button in UIKit and open the chatbot directly:

```swift
import UIKit
import RobylonSDK

class ViewController: UIViewController {
    
    private var chatbotConfig: ChatbotConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChatbot()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Custom chatbot button
        let chatButton = UIButton(type: .system)
        chatButton.setTitle("💬 Chat with Support", for: .normal)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        chatButton.backgroundColor = .systemBlue
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.layer.cornerRadius = 25
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        // Add button to view
        view.addSubview(chatButton)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chatButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chatButton.widthAnchor.constraint(equalToConstant: 200),
            chatButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupChatbot() {
        let userProfile = UserProfile(
            name: "Custom Button User",
            email: "user@example.com"
        )
        
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            userId: "custom-button-user-123",
            userToken: "auth-token-123",
            userProfile: userProfile,
            debugMode: true,
            eventHandler: { [weak self] event in
                print("📱 Custom Button Event: \(event.type.rawValue)")
                
                switch event.type {
                case .chatbotOpened:
                    print("🚀 Chatbot opened from custom button")
                case .chatbotClosed:
                    print("🔒 Chatbot closed from custom button")
                case .chatInitializationFailed:
                    if let error = event.data?["error"] as? String {
                        print("❌ Error: \(error)")
                        DispatchQueue.main.async {
                            self?.showErrorAlert(message: error)
                        }
                    }
                default:
                    break
                }
            },
            parentView: nil, // No automatic button
            presentationStyle: .default
        )
        
        self.chatbotConfig = config
    }
    
    @objc private func chatButtonTapped() {
        guard let config = chatbotConfig else {
            print("Chatbot not configured")
            return
        }
        
        // Open chatbot directly - will initialize if needed
        RobylonSDK.openChatbot(config: config)
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

### UIKit with Multiple Chatbot Triggers

For apps that need to open the chatbot from different places:

```swift
import UIKit
import RobylonSDK

class ChatbotManager {
    static let shared = ChatbotManager()
    private var config: ChatbotConfiguration?
    
    private init() {
        setupChatbot()
    }
    
    private func setupChatbot() {
        let config = ChatbotConfiguration(
            apiKey: "YOUR_API_KEY",
            debugMode: true,
            eventHandler: { event in
                print("Event: \(event.type.rawValue)")
            },
            parentView: nil
        )
        self.config = config
    }
    
    func openChatbot() {
        guard let config = config else { return }
        RobylonSDK.openChatbot(config: config)
    }
}

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let chatButton = UIButton(type: .system)
        chatButton.setTitle("Open Chat", for: .normal)
        chatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
        
        view.addSubview(chatButton)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chatButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func openChat() {
        ChatbotManager.shared.openChatbot()
    }
}

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let helpButton = UIButton(type: .system)
        helpButton.setTitle("Get Help", for: .normal)
        helpButton.addTarget(self, action: #selector(getHelp), for: .touchUpInside)
        
        view.addSubview(helpButton)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func getHelp() {
        ChatbotManager.shared.openChatbot()
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

## Installation Approaches

The SDK provides two main approaches for integrating the chatbot into your app:

### 1. **Automatic Button Integration** (`RobylonSDK.initializeChatbot`)
- **Use when**: You want the SDK to automatically create and manage the chatbot button
- **Benefits**: 
  - Zero UI code required
  - Button automatically positioned and styled based on API response
  - Handles all button lifecycle events
- **Configuration**: Set `parentView` to specify where the button should be added

### 2. **Direct Opening** (`RobylonSDK.openChatbot`)
- **Use when**: You have your own custom UI or want to trigger the chatbot programmatically
- **Benefits**:
  - Full control over button appearance and placement
  - Can trigger chatbot from anywhere in your app
  - No automatic button creation
  - Automatic initialization if needed
- **Configuration**: Set `parentView: nil` to disable automatic button creation

### When to Use Each Approach

| Use Case | Recommended Approach | Example |
|----------|---------------------|---------|
| **Simple integration** | `initializeChatbot` | Basic apps needing a chatbot button |
| **Custom UI design** | `openChatbot` | Apps with specific design requirements |
| **Multiple triggers** | `openChatbot` | Apps that open chatbot from different places |
| **Programmatic control** | `openChatbot` | Apps that need to control when chatbot opens |
| **Existing buttons** | `openChatbot` | Apps that already have chat/support buttons |

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

## Troubleshooting

### Common Issues with Direct Opening

#### 1. **Chatbot Not Opening**
- **Cause**: Configuration not properly set up
- **Solution**: Ensure `ChatbotConfiguration` is created with valid `apiKey`
- **Check**: Verify `parentView: nil` is set to disable automatic button

#### 2. **Initialization Takes Too Long**
- **Cause**: Network issues or API delays
- **Solution**: The SDK automatically handles timeouts and shows user-friendly messages
- **Check**: Verify your API key and network connectivity

#### 3. **Multiple Chatbot Instances**
- **Cause**: Calling `openChatbot` multiple times
- **Solution**: The SDK uses singleton pattern - only one instance will be created
- **Best Practice**: Store configuration once and reuse it

#### 4. **Event Handler Not Called**
- **Cause**: Event handler not properly configured
- **Solution**: Ensure `eventHandler` closure is properly set in configuration
- **Check**: Verify closure syntax and memory management (use `[weak self]` if needed)

### Debug Tips

```swift
// Enable debug mode for staging environment
let config = ChatbotConfiguration(
    apiKey: "your-api-key",
    debugMode: true, // This enables detailed logging
    // ... other parameters
)
```

## Support

For support and questions, please open an issue on GitHub or contact the development team.
