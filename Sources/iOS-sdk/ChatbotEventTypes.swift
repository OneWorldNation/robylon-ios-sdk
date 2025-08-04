import Foundation

// MARK: - Event Types
public enum ChatbotEventType: String, CaseIterable {
    case chatbotButtonLoaded = "CHATBOT_BUTTON_LOADED"
    case chatbotButtonClicked = "CHATBOT_BUTTON_CLICKED"
    case chatbotOpened = "CHATBOT_OPENED"
    case chatbotClosed = "CHATBOT_CLOSED"
    case chatbotAppReady = "CHATBOT_APP_READY"
    case chatbotLoaded = "CHATBOT_LOADED"
    case chatInitialized = "CHAT_INITIALIZED"
    case sessionRefreshed = "SESSION_REFRESHED"
    case chatInitializationFailed = "CHAT_INITIALIZATION_FAILED"
}

public enum InternalEventType: String, CaseIterable {
    case chatMoved = "CHAT_MOVED"
}

public typealias AllEventTypes = ChatbotEventType

// MARK: - Event Structure
public struct ChatbotEvent {
    public let type: ChatbotEventType
    public let timestamp: TimeInterval
    public let data: [String: Any]?
    
    public init(type: ChatbotEventType, data: [String: Any]? = nil) {
        self.type = type
        self.timestamp = Date().timeIntervalSince1970
        self.data = data
    }
}

// MARK: - User Profile
public struct UserProfile {
    public let name: String?
    public let email: String?
    
    public init(name: String? = nil, email: String? = nil) {
        self.name = name
        self.email = email
    }
    
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let name = name {
            dict["name"] = name
        }
        if let email = email {
            dict["email"] = email
        }
        return dict
    }
}

// MARK: - Event Handler Type
public typealias ChatbotEventHandler = (ChatbotEvent) -> Void 