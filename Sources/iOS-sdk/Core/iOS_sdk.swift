// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit

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
    
    public static func closeChatbot() {
        Chatbot.shared.closeChatbot()
    }
    
    public static func isChatbotOpen() -> Bool {
        return Chatbot.shared.isChatbotOpen()
    }
    
    public static func refreshChatbotSession() {
        Chatbot.shared.refreshSession()
    }
    
    // MARK: - MVVM Helper Methods
    public static func createChatbotViewModel() -> ChatbotViewModel {
        return ChatbotViewModel()
    }
    
    public static func createChatbotConfigurationViewModel() -> ChatbotConfigurationViewModel {
        return ChatbotConfigurationViewModel()
    }
    
    public static func createChatbotService() -> ChatbotServiceProtocol {
        return ChatbotService.shared
    }
    
    // MARK: - Utility Methods
    public static func validateAPIKey(_ apiKey: String) -> Bool {
        return ChatbotUtils.isValidAPIKey(apiKey)
    }
    
    public static func validateEmail(_ email: String) -> Bool {
        return ChatbotUtils.isValidEmail(email)
    }
    
    public static func validateUserId(_ userId: String) -> Bool {
        return ChatbotUtils.isValidUserId(userId)
    }
    
    public static func createStyledButton(
        title: String,
        backgroundColor: UIColor = ChatbotConstants.Colors.primaryBlue,
        textColor: UIColor = .white,
        cornerRadius: CGFloat = ChatbotConstants.defaultCornerRadius,
        fontSize: CGFloat = ChatbotConstants.defaultFontSize,
        fontWeight: UIFont.Weight = .medium
    ) -> UIButton {
        return ChatbotUtils.createStyledButton(
            title: title,
            backgroundColor: backgroundColor,
            textColor: textColor,
            cornerRadius: cornerRadius,
            fontSize: fontSize,
            fontWeight: fontWeight
        )
    }
}
