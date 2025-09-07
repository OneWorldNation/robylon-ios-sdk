import Foundation
import UIKit

// MARK: - API Models
struct ChatbotAPIRequest: Codable {
    let client_user_id: String
    let org_id: String
    let token: String
    let extra_info: [String: String]
    
    init(clientUserId: String, orgId: String, token: String, extraInfo: [String: String] = [:]) {
        self.client_user_id = clientUserId
        self.org_id = orgId
        self.token = token
        self.extra_info = extraInfo
    }
}

public struct ChatbotAPIResponse: Codable {
    let user: UserData?
    
    struct UserData: Codable {
        let org_info: OrgInfo?
    }
    
    struct OrgInfo: Codable {
        let brand_config: BrandConfig?
    }
    
    struct BrandConfig: Codable {
        public let name: String?
        public let banner: Banner?
        public let colors: Colors?
        public let footer: Footer?
        public let images: Images?
        public let tagline: String?
        public let chatbot_id: String?
        public let ai_disclaimer: AIDisclaimer?
        public let enable_banner: Bool?
        public let launcher_type: String?
        public let brand_logo_url: String?
        public let interface_type: String?
        public let created_by_name: String?
        public let launcher_properties: LauncherProperties?
        public let stream_ai_responses: Bool?
        public let enable_ai_disclaimer: Bool?
        public let enable_message_sound: Bool?
        public let enable_user_feedback: Bool?
        public let interface_properties: InterfaceProperties?
        let chat_iframe_url: String?
    }
    
    struct Banner: Codable {
        let title: String?
        let description: String?
    }
    
    struct Colors: Codable {
        let brand_color: String?
        let title_bar_color: String?
    }
    
    struct Footer: Codable {
        let footer_link: String?
        let show_powered_by: Bool?
        let footer_link_text: String?
        let message_box_value: String?
        let show_custom_footer: Bool?
    }
    
    struct Images: Codable {
        let agent_image_url: ImageData?
        let banner_image_url: ImageData?
        let header_image_url: ImageData?
        let launcher_image_url: ImageData?
    }
    
    struct ImageData: Codable {
        let url: String?
        let size: Int?
    }
    
    struct AIDisclaimer: Codable {
        let message: String?
    }
    
    struct LauncherProperties: Codable {
        let text: String?
    }
    
    struct InterfaceProperties: Codable {
        let position: String?
        let side_spacing: Int?
        let bottom_spacing: Int?
    }
}

// MARK: - Network Utilities
@MainActor
final class ChatbotNetworkUtils {
    
    /// Sets common HTTP headers for all chatbot API requests
    /// - Parameters:
    ///   - urlRequest: The URLRequest to set headers on
    ///   - config: The chatbot configuration to determine environment-specific values
    static func setCommonHeaders(_ urlRequest: inout URLRequest, config: ChatbotConfiguration) {
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        urlRequest.setValue("en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7", forHTTPHeaderField: "Accept-Language")
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        // Set origin based on debug mode
        let origin = config.debugMode ? "https://app-stage.robylon.ai" : "https://app.robylon.ai"
        urlRequest.setValue(origin, forHTTPHeaderField: "Origin")
        
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Pragma")
        urlRequest.setValue("u=1, i", forHTTPHeaderField: "Priority")
        
        // Set referer based on debug mode
        let referer = config.debugMode ? "https://app-stage.robylon.ai/" : "https://app.robylon.ai/"
        urlRequest.setValue(referer, forHTTPHeaderField: "Referer")
        
        urlRequest.setValue("\"Not)A;Brand\";v=\"8\", \"Chromium\";v=\"138\", \"Google Chrome\";v=\"138\"", forHTTPHeaderField: "Sec-Ch-Ua")
        urlRequest.setValue("?0", forHTTPHeaderField: "Sec-Ch-Ua-Mobile")
        urlRequest.setValue("\"macOS\"", forHTTPHeaderField: "Sec-Ch-Ua-Platform")
        urlRequest.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        urlRequest.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        urlRequest.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        
        // Set dynamic User-Agent
        urlRequest.setValue(getDynamicUserAgent(), forHTTPHeaderField: "User-Agent")
    }
    
    /// Generates a dynamic User-Agent string for iOS devices
    /// - Returns: A properly formatted User-Agent string
    private static func getDynamicUserAgent() -> String {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let systemName = device.systemName
        let model = device.model
        
        // Get app version and bundle identifier
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
        
        // Create a more realistic User-Agent for iOS
        return "iOS-Chatbot-SDK/\(appVersion) (\(bundleId)) \(systemName)/\(systemVersion) \(model)"
    }
}

// MARK: - Network Service
@MainActor
final class ChatbotNetworkService {
    
    // MARK: - Singleton
    static let shared = ChatbotNetworkService()
    
    // MARK: - Properties
    private let session = URLSession.shared
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    func initialiseChatbot(
        config: ChatbotConfiguration,
        completion: @escaping (Result<ChatbotAPIResponse, Error>) -> Void
    ) {
        let baseURL = config.debugMode ? ChatbotConstants.URLs.debugBaseURL : ChatbotConstants.URLs.productionBaseURL
        
        let finalOrgId = config.apiKey
        let clientUserId = config.userId ?? ""
        let token = config.userToken ?? ""
        let request = ChatbotAPIRequest(
            clientUserId: clientUserId,
            orgId: finalOrgId,
            token: token,
            extraInfo: [:]
        )
        guard let url = URL(string: "\(baseURL)/chat/chatbot/get/") else {
            completion(.failure(ChatbotNetworkError.invalidURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        // Set common headers
        ChatbotNetworkUtils.setCommonHeaders(&urlRequest, config: config)
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            ChatbotUtils.logInfo("Making API request to initialise chatbot")
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.handleAPIResponse(data: data, response: response, error: error, completion: completion)
                }
            }
            task.resume()
        } catch {
            ChatbotUtils.logError("Failed to encode request: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Private Methods
    private func handleAPIResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<ChatbotAPIResponse, Error>) -> Void
    ) {
        if let error = error {
            ChatbotUtils.logError("Network error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            ChatbotUtils.logError("No data received from API")
            completion(.failure(ChatbotNetworkError.noData))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            ChatbotUtils.logError("Invalid HTTP response")
            completion(.failure(ChatbotNetworkError.invalidResponse))
            return
        }
        
        ChatbotUtils.logInfo("API Response Status: \(httpResponse.statusCode)")
        
        do {
            let apiResponse = try JSONDecoder().decode(ChatbotAPIResponse.self, from: data)
            
            if httpResponse.statusCode == 200 {
                ChatbotUtils.logSuccess("Chatbot API initialization successful")
                completion(.success(apiResponse))
            } else {
                ChatbotUtils.logError("API Error: HTTP \(httpResponse.statusCode)")
                completion(.failure(ChatbotNetworkError.apiError("HTTP \(httpResponse.statusCode)")))
            }
            
        } catch {
            ChatbotUtils.logError("Failed to decode response: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    private func extractOrgId(from apiKey: String) -> String {
        // For now, using a default org_id. In production, this should be extracted from the apiKey
        // or provided separately in the configuration
        return "30e4fab6-cadb-4b99-b1e7-30fca6e147ac"
    }
    
    private func generateClientUserId() -> String {
        // Generate a unique client user ID if none provided
        return UUID().uuidString
    }
}

// MARK: - Network Errors
enum ChatbotNetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}

// MARK: - Analytics API Models
struct AnalyticsAPIRequest: Codable {
    let org_id: String
    let event_data: EventData
    let metadata: Metadata
    let event_type: String
    let user_id: String
    
    struct EventData: Codable {
        let trigger_time: Int64
        let channel: String
        let org_id: String
        let client_user_id: String
        let event_type: String
        let user_profile: [String: String]?
    }
    
    struct Metadata: Codable {
        let timestamp: Int64
        let platform: String
        let os: String
        let browser: String
        let sdk_version: String
        let device: String
        let screen_size: ScreenSize
    }
    
    struct ScreenSize: Codable {
        let width: Int
        let height: Int
    }
}

// MARK: - Analytics Service
@MainActor
final class ChatbotAnalyticsService {
    
    // MARK: - Singleton
    static let shared = ChatbotAnalyticsService()
    
    // MARK: - Properties
    private let session = URLSession.shared
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    func recordEvent(
        eventType: ChatbotEventType,
        config: ChatbotConfiguration,
        additionalData: [String: Any]? = nil
    ) {
        let baseURL = config.debugMode ? ChatbotConstants.URLs.debugBaseURL : ChatbotConstants.URLs.productionBaseURL
        
        let request = buildAnalyticsRequest(eventType: eventType, config: config, additionalData: additionalData)
        
        guard let url = URL(string: "\(baseURL)/users/sdk/record-logs/") else {
            ChatbotUtils.logError("Invalid analytics URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        // Set common headers
        ChatbotNetworkUtils.setCommonHeaders(&urlRequest, config: config)
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            ChatbotUtils.logInfo("Recording analytics event: \(eventType.rawValue)")
            
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.handleAnalyticsResponse(data: data, response: response, error: error, eventType: eventType)
                }
            }
            task.resume()
            
        } catch {
            ChatbotUtils.logError("Failed to encode analytics request: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func buildAnalyticsRequest(
        eventType: ChatbotEventType,
        config: ChatbotConfiguration,
        additionalData: [String: Any]?
    ) -> AnalyticsAPIRequest {
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        let screenSize = getScreenSize()
        
        let eventData = AnalyticsAPIRequest.EventData(
            trigger_time: currentTime,
            channel: "CHATBOT",
            org_id: config.apiKey,
            client_user_id: config.userId ?? "",
            event_type: eventType.rawValue,
            user_profile: convertUserProfileToStringDictionary(config.userProfile)
        )
        
        let metadata = AnalyticsAPIRequest.Metadata(
            timestamp: currentTime,
            platform: "ios",
            os: getOSInfo(),
            browser: "WebView",
            sdk_version: "1.0.1",
            device: getDeviceType(),
            screen_size: AnalyticsAPIRequest.ScreenSize(
                width: screenSize.width,
                height: screenSize.height
            )
        )
        
        return AnalyticsAPIRequest(
            org_id: config.apiKey,
            event_data: eventData,
            metadata: metadata,
            event_type: "INFO",
            user_id: config.userId ?? ""
        )
    }
    
    private func handleAnalyticsResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        eventType: ChatbotEventType
    ) {
        if let error = error {
            ChatbotUtils.logError("Analytics API error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            ChatbotUtils.logError("Invalid analytics HTTP response")
            return
        }
        
        if httpResponse.statusCode == 200 {
            ChatbotUtils.logSuccess("Analytics event recorded successfully: \(eventType.rawValue)")
        } else {
            ChatbotUtils.logError("Analytics API error: HTTP \(httpResponse.statusCode)")
        }
    }
    
    private func getScreenSize() -> (width: Int, height: Int) {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        return (
            width: Int(bounds.width * scale),
            height: Int(bounds.height * scale)
        )
    }
    
    private func getOSInfo() -> String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return "iOS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    }
    
    private func getDeviceType() -> String {
        let device = UIDevice.current
        if device.userInterfaceIdiom == .pad {
            return "tablet"
        } else if device.userInterfaceIdiom == .phone {
            return "mobile"
        } else {
            return "desktop"
        }
    }
    
    private func convertUserProfileToStringDictionary(_ userProfile: [String: Any]?) -> [String: String]? {
        guard let userProfile = userProfile else { return nil }
        
        var stringDictionary: [String: String] = [:]
        for (key, value) in userProfile {
            stringDictionary[key] = "\(value)"
        }
        return stringDictionary
    }
}
