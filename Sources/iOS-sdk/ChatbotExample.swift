import UIKit
import Foundation

// MARK: - Example Usage
@MainActor
public class ChatbotExample {
    
    public static func setupChatbot() {
        // Create user profile
        let userProfile = UserProfile(
            name: "John Doe",
            email: "john.doe@example.com"
        )
        
        // Define event handler
        let eventHandler: ChatbotEventHandler = { event in
            print("📱 Chatbot Event: \(event.type.rawValue)")
            print("   Timestamp: \(event.timestamp)")
            if let data = event.data {
                print("   Data: \(data)")
            }
            print("---")
        }
        
        // Initialize chatbot with all parameters
        iOS_sdk.initializeChatbot(
            apiKey: "YOUR_API_KEY", // Mandatory
            userId: "optional-user-id",
            userToken: "optional-auth-token",
            userProfile: userProfile,
            eventHandler: eventHandler
        )
    }
    
    public static func createChatbotButton() -> UIButton? {
        return iOS_sdk.createChatbotButton()
    }
    
    public static func demonstrateUsage() {
        // 1. Initialize the chatbot
        setupChatbot()
        
        // 2. Create a button (this will be done in your view controller)
        if let button = createChatbotButton() {
            // Configure button appearance
            button.setTitle("Open Chatbot", for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            // Add to your view hierarchy
            // view.addSubview(button)
            // Set up constraints...
        }
        
        // 3. Alternative: Open chatbot programmatically
        // iOS_sdk.openChatbot()
        
        // 4. Check if chatbot is open
        let isOpen = iOS_sdk.isChatbotOpen()
        print("Chatbot is open: \(isOpen)")
        
        // 5. Refresh session if needed
        // iOS_sdk.refreshChatbotSession()
        
        // 6. Close chatbot programmatically
        // iOS_sdk.closeChatbot()
    }
}

// MARK: - View Controller Example
@MainActor
public class ExampleViewController: UIViewController {
    
    private var chatbotButton: UIButton?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupChatbot()
        setupUI()
    }
    
    private func setupChatbot() {
        // Initialize chatbot with event handling
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
            // Handle chatbot events
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Create chatbot button
        chatbotButton = iOS_sdk.createChatbotButton()
        
        if let button = chatbotButton {
            button.setTitle("💬 Open Chatbot", for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(button)
            
            // Center the button
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
} 