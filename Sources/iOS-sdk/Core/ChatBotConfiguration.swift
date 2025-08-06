import Foundation

// MARK: - Chatbot Configuration
public struct ChatbotConfiguration {
    public let apiKey: String
    public let orgId: String?
    public let userId: String?
    public let userToken: String?
    public let userProfile: UserProfile?
    public let eventHandler: ChatbotEventHandler?
    public let parentFrame: CGRect?
    
    public init(
        apiKey: String,
        orgId: String? = nil,
        userId: String? = nil,
        userToken: String? = nil,
        userProfile: UserProfile? = nil,
        eventHandler: ChatbotEventHandler? = nil,
        parentFrame: CGRect? = nil
    ) {
        self.apiKey = apiKey
        self.orgId = orgId
        self.userId = userId
        self.userToken = userToken
        self.userProfile = userProfile
        self.eventHandler = eventHandler
        self.parentFrame = parentFrame
    }
}