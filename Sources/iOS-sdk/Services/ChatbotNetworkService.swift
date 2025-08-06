import Foundation
import UIKit

// MARK: - API Models
public struct ChatbotAPIRequest: Codable {
    public let client_user_id: String
    public let org_id: String
    public let token: String
    public let extra_info: [String: String]
    
    public init(clientUserId: String, orgId: String, token: String, extraInfo: [String: String] = [:]) {
        self.client_user_id = clientUserId
        self.org_id = orgId
        self.token = token
        self.extra_info = extraInfo
    }
}

public struct ChatbotAPIResponse: Codable {
    public let user: UserData?
    
    public struct UserData: Codable {
        public let org_info: OrgInfo?
    }
    
    public struct OrgInfo: Codable {
        public let brand_config: BrandConfig?
    }
    
    public struct BrandConfig: Codable {
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
    }
    
    public struct Banner: Codable {
        public let title: String?
        public let description: String?
    }
    
    public struct Colors: Codable {
        public let brand_color: String?
        public let title_bar_color: String?
    }
    
    public struct Footer: Codable {
        public let footer_link: String?
        public let show_powered_by: Bool?
        public let footer_link_text: String?
        public let message_box_value: String?
        public let show_custom_footer: Bool?
    }
    
    public struct Images: Codable {
        public let agent_image_url: ImageData?
        public let banner_image_url: ImageData?
        public let header_image_url: ImageData?
        public let launcher_image_url: ImageData?
    }
    
    public struct ImageData: Codable {
        public let url: String?
        public let size: Int?
    }
    
    public struct AIDisclaimer: Codable {
        public let message: String?
    }
    
    public struct LauncherProperties: Codable {
        public let text: String?
    }
    
    public struct InterfaceProperties: Codable {
        public let position: String?
        public let side_spacing: Int?
        public let bottom_spacing: Int?
    }
}

// MARK: - Network Service
@MainActor
public class ChatbotNetworkService {
    
    // MARK: - Singleton
    public static let shared = ChatbotNetworkService()
    
    // MARK: - Properties
    private let baseURL = "https://stage-api.robylon.ai"
    private let session = URLSession.shared
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func initialiseChatbot(
        config: ChatbotConfiguration,
        completion: @escaping (Result<ChatbotAPIResponse, Error>) -> Void
    ) {
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
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        urlRequest.setValue("en-GB,en-US;q=0.9,en;q=0.8,hi;q=0.7", forHTTPHeaderField: "Accept-Language")
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        urlRequest.setValue("https://app-stage.robylon.ai", forHTTPHeaderField: "Origin")
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Pragma")
        urlRequest.setValue("u=1, i", forHTTPHeaderField: "Priority")
        urlRequest.setValue("https://app-stage.robylon.ai/", forHTTPHeaderField: "Referer")
        urlRequest.setValue("\"Not)A;Brand\";v=\"8\", \"Chromium\";v=\"138\", \"Google Chrome\";v=\"138\"", forHTTPHeaderField: "Sec-Ch-Ua")
        urlRequest.setValue("?0", forHTTPHeaderField: "Sec-Ch-Ua-Mobile")
        urlRequest.setValue("\"macOS\"", forHTTPHeaderField: "Sec-Ch-Ua-Platform")
        urlRequest.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        urlRequest.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        urlRequest.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        urlRequest.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            ChatbotUtils.logInfo("Making API request to initialise chatbot")
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.handleAPIResponse(data: data, response: response, error: error, completion: completion)
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
                ChatbotUtils.logSuccess("Chatbot initialization successful")
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
public enum ChatbotNetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case apiError(String)
    
    public var errorDescription: String? {
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
