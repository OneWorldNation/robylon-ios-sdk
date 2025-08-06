// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit
import Foundation

// MARK: - iOS SDK Main Interface
@MainActor
public struct iOS_sdk {
    public static func createButton(action: @escaping (String) -> Void) -> UIButton {
        return CustomButton(callback: action)
    }
    
    // MARK: - Chatbot Methods
    public static func initializeChatbot(config: ChatbotConfiguration) {
        Chatbot.shared.initialize(config: config)
    }
    
    public static func createChatbotButton() -> UIButton? {
        return Chatbot.shared.createButton()
    }
    
    public static func openChatbot() {
        Chatbot.shared.openChatbot()
    }
    
    public static func refreshSession() {
        Chatbot.shared.refreshSession()
    }
    
    // MARK: - Custom Button Methods
    public static func createCustomButton(config: CustomBottomConfig, action: @escaping (String) -> Void) -> UIButton {
        return CustomButton(config: config, callback: action)
    }
    
    public static func createStyledButton(
        title: String? = nil,
        backgroundColor: String? = nil,
        imageURL: String? = nil,
        action: @escaping (String) -> Void
    ) -> UIButton {
        let config = CustomBottomConfig(
            launchType: "TEXT",
            imageURL: imageURL,
            title: title,
            backgroundColor: backgroundColor,
            interfaceProperties: nil
        )
        return CustomButton(config: config, callback: action)
    }
    
    // MARK: - MVVM Components
    public static func createChatbotViewModel() -> ChatbotViewModel {
        return ChatbotViewModel()
    }
    
    public static func createChatbotConfigurationViewModel() -> ChatbotConfigurationViewModel {
        return ChatbotConfigurationViewModel()
    }
    
    public static func createChatbotService() -> ChatbotServiceProtocol {
        return ChatbotService.shared
    }
}
