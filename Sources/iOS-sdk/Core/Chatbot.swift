import UIKit
import Foundation

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
    public func initialize(config: ChatbotConfiguration) {
        guard !isInitialized else {
            print("Chatbot is already initialized")
            return
        }
        
        guard !config.apiKey.isEmpty else {
            let event = ChatbotEvent(type: .chatInitializationFailed, data: ["error": "API key is required"])
            config.eventHandler?(event)
            return
        }
        
        // Make API call to validate chatbot
        ChatbotNetworkService.shared.initialiseChatbot(
            config: config
        ) { [weak self] result in
            switch result {
            case .success(let apiResponse):
                self?.completeInitialization(with: config, apiResponse: apiResponse)
            case .failure(let error):
                let event = ChatbotEvent(
                    type: .chatInitializationFailed,
                    data: ["error": error.localizedDescription]
                )
                config.eventHandler?(event)
                ChatbotUtils.logError("Chatbot initialization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func completeInitialization(with config: ChatbotConfiguration, apiResponse: ChatbotAPIResponse) {
        self.configuration = config
        self.isInitialized = true
        
        // Emit initialization success event
        let event = ChatbotEvent(type: .chatInitialized, data: [
            "apiKey": config.apiKey,
            "orgId": config.orgId ?? "",
            "userId": config.userId ?? "",
            "hasUserToken": config.userToken != nil,
            "hasUserProfile": config.userProfile != nil,
            "apiResponse": [
                "success": apiResponse.success,
                "message": apiResponse.message ?? "",
                "chatbotId": apiResponse.data?.chatbot_id ?? "",
                "chatbotName": apiResponse.data?.chatbot_name ?? "",
                "chatbotUrl": apiResponse.data?.chatbot_url ?? "",
                "status": apiResponse.data?.status ?? ""
            ]
        ])
        config.eventHandler?(event)
        
        ChatbotUtils.logSuccess("Chatbot initialized successfully with API key: \(config.apiKey)")
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