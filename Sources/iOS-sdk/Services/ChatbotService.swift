import Foundation
import UIKit

// MARK: - Chatbot Service Protocol
public protocol ChatbotServiceProtocol {
    func initializeChatbot(with config: ChatbotConfiguration) -> Bool
    func createButton() -> UIButton?
    func openChatbot()
    func closeChatbot()
    func refreshSession()
    func isChatbotOpen() -> Bool
    func reset()
    func getConfiguration() -> ChatbotConfiguration?
}

// MARK: - Chatbot Service
@MainActor
public class ChatbotService: ChatbotServiceProtocol {
    
    // MARK: - Singleton
    public static let shared = ChatbotService()
    
    // MARK: - Private Properties
    private var configuration: ChatbotConfiguration?
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func initializeChatbot(with config: ChatbotConfiguration) -> Bool {
        guard !config.apiKey.isEmpty else {
            print("❌ Chatbot initialization failed: API key is required")
            return false
        }
        
        self.configuration = config
        Chatbot.shared.initialize(with: config)
        
        print("✅ Chatbot service initialized successfully")
        return true
    }
    
    public func createButton() -> UIButton? {
        guard let config = configuration else {
            print("❌ Chatbot service not initialized")
            return nil
        }
        
        return Chatbot.shared.createButton()
    }
    
    public func openChatbot() {
        guard let config = configuration else {
            print("❌ Chatbot service not initialized")
            return
        }
        
        Chatbot.shared.openChatbot()
    }
    
    public func closeChatbot() {
        Chatbot.shared.closeChatbot()
    }
    
    public func refreshSession() {
        guard let config = configuration else {
            print("❌ Chatbot service not initialized")
            return
        }
        
        Chatbot.shared.refreshSession()
    }
    
    public func isChatbotOpen() -> Bool {
        return Chatbot.shared.isChatbotOpen()
    }
    
    public func reset() {
        Chatbot.shared.reset()
        configuration = nil
        print("🔄 Chatbot service reset")
    }
    
    public func getConfiguration() -> ChatbotConfiguration? {
        return configuration
    }
}

// MARK: - Chatbot Analytics Service
@MainActor
public class ChatbotAnalyticsService {
    
    // MARK: - Singleton
    public static let shared = ChatbotAnalyticsService()
    
    // MARK: - Private Properties
    private var eventLog: [ChatbotEvent] = []
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func logEvent(_ event: ChatbotEvent) {
        eventLog.append(event)
        print("📊 Analytics: \(event.type.rawValue) at \(Date(timeIntervalSince1970: event.timestamp))")
    }
    
    public func getEventLog() -> [ChatbotEvent] {
        return eventLog
    }
    
    public func clearEventLog() {
        eventLog.removeAll()
    }
    
    public func getEventCount(for type: ChatbotEventType) -> Int {
        return eventLog.filter { $0.type == type }.count
    }
    
    public func getRecentEvents(limit: Int = 10) -> [ChatbotEvent] {
        return Array(eventLog.suffix(limit))
    }
}

// MARK: - Chatbot Configuration Service
@MainActor
public class ChatbotConfigurationService {
    
    // MARK: - Singleton
    public static let shared = ChatbotConfigurationService()
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let configKey = "ChatbotConfiguration"
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func saveConfiguration(_ config: ChatbotConfiguration) {
        let configData: [String: Any] = [
            "apiKey": config.apiKey,
            "userId": config.userId ?? "",
            "userToken": config.userToken ?? "",
            "userProfileName": config.userProfile?.name ?? "",
            "userProfileEmail": config.userProfile?.email ?? ""
        ]
        
        userDefaults.set(configData, forKey: configKey)
        print("💾 Configuration saved")
    }
    
    public func loadConfiguration() -> ChatbotConfiguration? {
        guard let configData = userDefaults.dictionary(forKey: configKey) else {
            return nil
        }
        
        let apiKey = configData["apiKey"] as? String ?? ""
        let userId = configData["userId"] as? String
        let userToken = configData["userToken"] as? String
        let userName = configData["userProfileName"] as? String
        let userEmail = configData["userProfileEmail"] as? String
        
        let userProfile = UserProfile(
            name: userName?.isEmpty == false ? userName : nil,
            email: userEmail?.isEmpty == false ? userEmail : nil
        )
        
        return ChatbotConfiguration(
            apiKey: apiKey,
            userId: userId?.isEmpty == false ? userId : nil,
            userToken: userToken?.isEmpty == false ? userToken : nil,
            userProfile: userProfile,
            eventHandler: nil
        )
    }
    
    public func clearConfiguration() {
        userDefaults.removeObject(forKey: configKey)
        print("🗑️ Configuration cleared")
    }
    
    public func hasSavedConfiguration() -> Bool {
        return userDefaults.object(forKey: configKey) != nil
    }
} 