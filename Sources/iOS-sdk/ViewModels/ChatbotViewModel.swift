import UIKit
import Foundation
import Combine

// MARK: - Chatbot View Model
@MainActor
public class ChatbotViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isInitialized: Bool = false
    @Published public var isChatbotOpen: Bool = false
    @Published public var lastEvent: ChatbotEvent?
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var configuration: ChatbotConfiguration?
    
    // MARK: - Public Methods
    public func initializeChatbot(
        apiKey: String,
        orgId: String? = nil,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: UserProfile? = nil
    ) {
        guard !apiKey.isEmpty else {
            errorMessage = "API key is required"
            return
        }
        
        let eventHandler: ChatbotEventHandler = { [weak self] event in
            self?.handleEvent(event)
        }
        
        let config = ChatbotConfiguration(
            apiKey: apiKey,
            orgId: orgId,
            userId: userId,
            userToken: userToken,
            userProfile: userProfile,
            eventHandler: eventHandler
        )
        
        self.configuration = config
        Chatbot.shared.initialize(with: config)
    }
    
    public func createChatbotButton() -> UIButton? {
        guard isInitialized else {
            errorMessage = "Chatbot must be initialized before creating button"
            return nil
        }
        
        return Chatbot.shared.createButton()
    }
    
    public func openChatbot() {
        guard isInitialized else {
            errorMessage = "Chatbot must be initialized before opening"
            return
        }
        
        Chatbot.shared.openChatbot()
    }
    
    public func closeChatbot() {
        Chatbot.shared.closeChatbot()
    }
    
    public func refreshSession() {
        guard isInitialized else { return }
        Chatbot.shared.refreshSession()
    }
    
    public func checkChatbotStatus() {
        isChatbotOpen = Chatbot.shared.isChatbotOpen()
    }
    
    public func reset() {
        Chatbot.shared.reset()
        isInitialized = false
        isChatbotOpen = false
        lastEvent = nil
        errorMessage = nil
        configuration = nil
    }
    
    // MARK: - Private Methods
    private func handleEvent(_ event: ChatbotEvent) {
        lastEvent = event
        
        switch event.type {
        case .chatInitialized:
            isInitialized = true
            errorMessage = nil
        case .chatInitializationFailed:
            isInitialized = false
            if let error = event.data?["error"] as? String {
                errorMessage = error
            }
        case .chatbotOpened:
            isChatbotOpen = true
        case .chatbotClosed:
            isChatbotOpen = false
        default:
            break
        }
        
        // Log event for debugging
        print("📱 Chatbot Event: \(event.type.rawValue)")
        if let data = event.data {
            print("   Data: \(data)")
        }
    }
}

// MARK: - Chatbot Configuration View Model
@MainActor
public class ChatbotConfigurationViewModel: ObservableObject {
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Published Properties
    @Published public var apiKey: String = ""
    @Published public var orgId: String = ""
    @Published public var userId: String = ""
    @Published public var userToken: String = ""
    @Published public var userName: String = ""
    @Published public var userEmail: String = ""
    
    // MARK: - Computed Properties
    public var userProfile: UserProfile? {
        guard !userName.isEmpty || !userEmail.isEmpty else { return nil }
        return UserProfile(
            name: userName.isEmpty ? nil : userName,
            email: userEmail.isEmpty ? nil : userEmail
        )
    }
    
    public var isConfigurationValid: Bool {
        !apiKey.isEmpty
    }
    
    public var configurationSummary: String {
        var summary = "API Key: \(apiKey)"
        if !orgId.isEmpty {
            summary += "\nOrg ID: \(orgId)"
        }
        if !userId.isEmpty {
            summary += "\nUser ID: \(userId)"
        }
        if !userToken.isEmpty {
            summary += "\nUser Token: \(userToken)"
        }
        if let profile = userProfile {
            summary += "\nUser Profile: \(profile.name ?? "N/A"), \(profile.email ?? "N/A")"
        }
        return summary
    }
    
    // MARK: - Public Methods
    public func resetConfiguration() {
        apiKey = ""
        orgId = ""
        userId = ""
        userToken = ""
        userName = ""
        userEmail = ""
    }
    
    public func loadDefaultConfiguration() {
        apiKey = "YOUR_API_KEY"
        orgId = "30e4fab6-cadb-4b99-b1e7-30fca6e147ac"
        userId = "demo-user-123"
        userToken = "demo-token-456"
        userName = "Demo User"
        userEmail = "demo@example.com"
    }
} 