import UIKit
import Foundation

// MARK: - Chatbot Configuration
public struct ChatbotConfiguration {
    public let apiKey: String
    public let userId: String?
    public let userToken: String?
    public let userProfile: UserProfile?
    public let eventHandler: ChatbotEventHandler?
    
    public init(
        apiKey: String,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: UserProfile? = nil,
        eventHandler: ChatbotEventHandler? = nil
    ) {
        self.apiKey = apiKey
        self.userId = userId
        self.userToken = userToken
        self.userProfile = userProfile
        self.eventHandler = eventHandler
    }
}

// MARK: - Chatbot Singleton
@MainActor
public class Chatbot {
    public static let shared = Chatbot()
    
    // MARK: - Properties
    private var configuration: ChatbotConfiguration?
    private var isInitialized = false
    private var webViewController: WebViewController?
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func initialize(with config: ChatbotConfiguration) {
        guard !isInitialized else {
            print("Chatbot is already initialized")
            return
        }
        
        guard !config.apiKey.isEmpty else {
            let event = ChatbotEvent(type: .chatInitializationFailed, data: ["error": "API key is required"])
            config.eventHandler?(event)
            return
        }
        
        self.configuration = config
        self.isInitialized = true
        
        // Emit initialization success event
        let event = ChatbotEvent(type: .chatInitialized, data: [
            "apiKey": config.apiKey,
            "userId": config.userId ?? "",
            "hasUserToken": config.userToken != nil,
            "hasUserProfile": config.userProfile != nil
        ])
        config.eventHandler?(event)
        
        print("Chatbot initialized successfully with API key: \(config.apiKey)")
    }
    
    public func createButton() -> UIButton? {
        guard isInitialized, let config = configuration else {
            print("Chatbot must be initialized before creating button")
            return nil
        }
        
        let button = CustomButton { [weak self] message in
            self?.handleButtonCallback(message)
        }
        
        // Emit button loaded event
        let event = ChatbotEvent(type: .chatbotButtonLoaded)
        config.eventHandler?(event)
        
        return button
    }
    
    public func openChatbot() {
        guard isInitialized, let config = configuration else {
            print("Chatbot must be initialized before opening")
            return
        }
        
        // Emit button clicked event
        let buttonEvent = ChatbotEvent(type: .chatbotButtonClicked)
        config.eventHandler?(buttonEvent)
        
        // Create and present WebViewController
        let webVC = WebViewController()
        webVC.apiKey = config.apiKey
        webVC.userId = config.userId
        webVC.userToken = config.userToken
        webVC.userProfile = config.userProfile
        webVC.eventHandler = config.eventHandler
        
        self.webViewController = webVC
        
        // Emit chatbot opened event
        let openedEvent = ChatbotEvent(type: .chatbotOpened)
        config.eventHandler?(openedEvent)
        
        // Present the WebViewController
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(webVC, animated: true) {
                // Emit app ready event after presentation
                let appReadyEvent = ChatbotEvent(type: .chatbotAppReady)
                config.eventHandler?(appReadyEvent)
            }
        }
    }
    
    public func closeChatbot() {
        guard let webVC = webViewController else { return }
        
        webVC.dismiss(animated: true) { [weak self] in
            guard let self = self, let config = self.configuration else { return }
            
            // Emit chatbot closed event
            let event = ChatbotEvent(type: .chatbotClosed)
            config.eventHandler?(event)
            
            self.webViewController = nil
        }
    }
    
    public func refreshSession() {
        guard isInitialized, let config = configuration else { return }
        
        let event = ChatbotEvent(type: .sessionRefreshed)
        config.eventHandler?(event)
    }
    
    public func isChatbotOpen() -> Bool {
        return webViewController != nil
    }
    
    // MARK: - Private Methods
    private func handleButtonCallback(_ message: String) {
        guard let config = configuration else { return }
        
        // Handle any button callbacks here
        print("Button callback received: \(message)")
    }
    
    // MARK: - Utility Methods
    public func getConfiguration() -> ChatbotConfiguration? {
        return configuration
    }
    
    public func reset() {
        configuration = nil
        isInitialized = false
        webViewController = nil
    }
} 