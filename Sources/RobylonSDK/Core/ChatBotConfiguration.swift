import Foundation
import UIKit

// MARK: - Chatbot Configuration
/// Represents the configuration settings for the chatbot.
/// This struct encapsulates all necessary parameters to initialize and manage the chatbot's behavior.
/// /// - Parameters:
///   - apiKey: The API key for authenticating with the chatbot service.
///   - orgId: Optional organization ID for multi-tenancy support.
///   - userId: Optional user ID, defaults to a UUID if not provided.
///   - userToken: Optional user token for session management.
///   - userProfile: Optional user profile dictionary containing additional user information.
///   - debugMode: A boolean indicating whether to enable debug mode (default is false). This is done to test  chatbot SDK in debug mode. Connecting to the staging server for testing purposes. While releaseing your app please make sure debugMode is set to false.
///   - eventHandler: Optional event handler for handling chatbot events.
///   - parentView: Optional parent view for presenting the chatbot UI.
///   - presetationStyle: The presentation style for the chatbot UI, default is `.default`.   The chatbot view will be presented in the specified style; in full screen or default sheet like structure.

public struct ChatbotConfiguration {
    let apiKey: String
    let orgId: String?
    let userId: String
    let userToken: String?
    let userProfile: [String: Any]?
    let debugMode: Bool // Default to false, can be set to true for debugging
    let eventHandler: ChatbotEventHandler?
    let parentView: UIView?
    let presentationStyle: ChatBotPresentationStyle
    
    public init(
        apiKey: String,
        orgId: String? = nil,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: [String: Any]? = nil,
        eventHandler: ChatbotEventHandler? = nil,
        parentView: UIView? = nil,
        debugMode: Bool = false, // Default value for debug mode
        presentationStyle: ChatBotPresentationStyle = .default // Default presentation style
    ) {
        self.apiKey = apiKey
        self.orgId = orgId
        self.userId = userId ?? UUID().uuidString // Generate a UUID if userId is nil
        self.userToken = userToken
        self.userProfile = userProfile
        self.eventHandler = eventHandler
        self.parentView = parentView
        self.debugMode = debugMode
        self.presentationStyle = presentationStyle
    }
}

public enum ChatBotPresentationStyle {
    case `default`
    case fullscreen
    
    var modalPresentationStyle: UIModalPresentationStyle {
        switch self {
        case .default:
            return .automatic
        case .fullscreen:
            return .fullScreen
        }
    }
}
