// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit

@MainActor
public struct iOS_sdk {
    public static func createButton(action: @escaping (String) -> Void) -> UIButton {
        return CustomButton(callback: action)
    }
    
    // MARK: - Chatbot Methods
    public static func initializeChatbot(
        apiKey: String,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: UserProfile? = nil,
        eventHandler: ChatbotEventHandler? = nil
    ) {
        let config = ChatbotConfiguration(
            apiKey: apiKey,
            userId: userId,
            userToken: userToken,
            userProfile: userProfile,
            eventHandler: eventHandler
        )
        Chatbot.shared.initialize(with: config)
    }
    
    public static func createChatbotButton() -> UIButton? {
        return Chatbot.shared.createButton()
    }
    
    public static func openChatbot() {
        Chatbot.shared.openChatbot()
    }
    
    public static func closeChatbot() {
        Chatbot.shared.closeChatbot()
    }
    
    public static func isChatbotOpen() -> Bool {
        return Chatbot.shared.isChatbotOpen()
    }
    
    public static func refreshChatbotSession() {
        Chatbot.shared.refreshSession()
    }
}
