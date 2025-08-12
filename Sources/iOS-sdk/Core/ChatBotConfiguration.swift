import Foundation
import UIKit

// MARK: - Chatbot Configuration
public struct ChatbotConfiguration {
    let apiKey: String
    let orgId: String?
    let userId: String
    let userToken: String?
    let userProfile: UserProfile?
    let debugMode: Bool // Default to false, can be set to true for debugging
    let eventHandler: ChatbotEventHandler?
    let parentView: UIView?
    
    public init(
        apiKey: String,
        orgId: String? = nil,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: UserProfile? = nil,
        eventHandler: ChatbotEventHandler? = nil,
        parentView: UIView? = nil,
        debugMode: Bool = false // Default value for debug mode
    ) {
        self.apiKey = apiKey
        self.orgId = orgId
        self.userId = userId ?? UUID().uuidString // Generate a UUID if userId is nil
        self.userToken = userToken
        self.userProfile = userProfile
        self.eventHandler = eventHandler
        self.parentView = parentView
        self.debugMode = debugMode
    }
}
