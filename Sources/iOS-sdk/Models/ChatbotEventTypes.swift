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
    
    public init(type: ChatbotEventType, timestamp: TimeInterval = Date().timeIntervalSince1970, data: [String: Any]? = nil) {
        self.type = type
        self.timestamp = timestamp
        self.data = data
    }
}

// MARK: - User Profile
public struct UserProfile: Codable {
    public let name: String?
    public let email: String?
    
    public init(name: String? = nil, email: String? = nil) {
        self.name = name
        self.email = email
    }
}

// MARK: - Event Handler Type
public typealias ChatbotEventHandler = (ChatbotEvent) -> Void 

// MARK: - Custom Bottom Configuration
struct CustomButtonConfig {
    public let launchType: String?
    public let imageURL: String?
    public let title: String?
    public let backgroundColor: String?
    public let interfaceProperties: ChatbotAPIResponse.InterfaceProperties?
    public let chatBotUrl: String
    
    init(
        launchType: String? = nil,
        imageURL: String? = nil,
        title: String? = nil,
        backgroundColor: String? = nil,
        interfaceProperties: ChatbotAPIResponse.InterfaceProperties? = nil,
        chatbotUrl: String
    ) {
        self.launchType = launchType
        self.imageURL = imageURL
        self.title = title
        self.backgroundColor = backgroundColor
        self.interfaceProperties = interfaceProperties
        self.chatBotUrl = chatbotUrl
    }
    
    // Factory method to create from API response
    static func from(apiResponse: ChatbotAPIResponse) -> CustomButtonConfig {
        let brandConfig = apiResponse.user?.org_info?.brand_config
        
        return CustomButtonConfig(
            launchType: brandConfig?.launcher_type,
            imageURL: brandConfig?.images?.launcher_image_url?.url,
            title: brandConfig?.launcher_properties?.text,
            backgroundColor: brandConfig?.colors?.brand_color,
            interfaceProperties: brandConfig?.interface_properties,
            chatbotUrl: brandConfig?.chat_iframe_url ?? ""
        )
    }
} 
