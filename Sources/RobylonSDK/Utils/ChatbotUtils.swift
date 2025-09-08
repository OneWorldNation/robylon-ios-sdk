import Foundation
import UIKit

// MARK: - Chatbot Utilities
struct ChatbotUtils {
    
    // MARK: - Validation
    static func isValidAPIKey(_ apiKey: String) -> Bool {
        return !apiKey.isEmpty && apiKey.count >= 10
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidUserId(_ userId: String) -> Bool {
        return !userId.isEmpty && userId.count >= 3
    }
    
    // MARK: - UI Helpers
    @MainActor
    static func createStyledButton(
        title: String,
        backgroundColor: UIColor = .systemBlue,
        textColor: UIColor = .white,
        cornerRadius: CGFloat = 12,
        fontSize: CGFloat = 16,
        fontWeight: UIFont.Weight = .medium
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return button
    }
    
    // MARK: - Logging
    static func logInfo(_ message: String) {
        print("ℹ️ [Chatbot] \(message)")
    }
    
    static func logWarning(_ message: String) {
        print("⚠️ [Chatbot] \(message)")
    }
    
    static func logError(_ message: String) {
        print("❌ [Chatbot] \(message)")
    }
    
    static func logSuccess(_ message: String) {
        print("✅ [Chatbot] \(message)")
    }
    
    // MARK: - Date Formatting
    static func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - JSON Helpers
    static func dictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    static func jsonToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    // MARK: - System Info
    static func getSystemInfo() -> (platform: String, os: String, browser: String, sdk_version: String, device: String, screen_size: String) {
        let platform = "iOS"
        let os = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let browser = "WebView"
        let sdk_version = "1.0.0" // You can update this to your actual SDK version
        
        // Get device type
        let device: String
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            device = "iPhone"
        case .pad:
            device = "iPad"
        case .tv:
            device = "Apple TV"
        case .carPlay:
            device = "CarPlay"
        case .mac:
            device = "Mac"
        @unknown default:
            device = "Unknown"
        }
        
        // Get screen size
        let screen = UIScreen.main.bounds
        let screen_size = "\(Int(screen.width))x\(Int(screen.height))"
        
        return (platform, os, browser, sdk_version, device, screen_size)
    }
    
    // MARK: - User Profile JSON Creation
    static func createUserProfileJavaScript(from userProfile: [String: Any]?, systemInfo: (platform: String, os: String, browser: String, sdk_version: String, device: String, screen_size: String)) -> String {
        var profileItems: [Any] = []
        
        // Add system info first
        profileItems.append(("platform", systemInfo.platform))
        profileItems.append(("os", systemInfo.os))
        profileItems.append(("browser", systemInfo.browser))
        profileItems.append(("sdk_version", systemInfo.sdk_version))
        profileItems.append(("device", systemInfo.device))
        profileItems.append(("screen_size", systemInfo.screen_size))
        
        // Add all user profile key-value pairs
        if let userProfile = userProfile {
            for (key, value) in userProfile {
                profileItems.append((key, value))
            }
        }
        
        // Add isTestUser if not present
        if userProfile?[ChatbotConstants.isTestUser] == nil {
            profileItems.append((ChatbotConstants.isTestUser, false))
        }
        
        return convertToJSONString(profileItems)
    }
    
    private static func convertToJSONString(_ profileItems: [Any]) -> String {
        var jsonParts: [String] = []
        
        for item in profileItems {
            if let (key, value) = item as? (String, Any) {
                let escapedKey = key.replacingOccurrences(of: "\"", with: "\\\"")
                let jsonValue = formatValueForJSON(value)
                jsonParts.append("\"\(escapedKey)\": \(jsonValue)")
            }
        }
        
        return "{ " + jsonParts.joined(separator: ", ") + " }"
    }
    
    private static func formatValueForJSON(_ value: Any) -> String {
        switch value {
        case is String:
            let escapedString = "\(value)".replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escapedString)\""
        case is Bool:
            return "\(value)"
        case is Int, is Double, is Float:
            return "\(value)"
        case is NSNull:
            return "null"
        case let array as [Any]:
            let formattedArray = array.map { formatValueForJSON($0) }.joined(separator: ", ")
            return "[\(formattedArray)]"
        case let dict as [String: Any]:
            let formattedDict = dict.map { key, val in
                let escapedKey = key.replacingOccurrences(of: "\"", with: "\\\"")
                return "\"\(escapedKey)\": \(formatValueForJSON(val))"
            }.joined(separator: ", ")
            return "{\(formattedDict)}"
        default:
            // For any other type, convert to string and escape
            let escapedString = "\(value)".replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escapedString)\""
        }
    }
    
    static func getBestFontColor(for backgroundColor: UIColor, contrastThreshold: CGFloat = 0.5) -> UIColor {
        let whiteShade = UIColor.white
        let blackShade = UIColor(red: 14/255, green: 14/255, blue: 15/255, alpha: 1)

        // Function to calculate luminance
        func luminance(_ color: UIColor) -> CGFloat {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let adjust: (CGFloat) -> CGFloat = { v in
                return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
            }
            
            return (adjust(r) * 0.2126) +
                   (adjust(g) * 0.7152) +
                   (adjust(b) * 0.0722)
        }

        let bgLuminance = luminance(backgroundColor)
        return bgLuminance > contrastThreshold ? blackShade : whiteShade
    }
}

// MARK: - Extensions
extension String {
    var isValidAPIKey: Bool {
        return ChatbotUtils.isValidAPIKey(self)
    }
    
    var isValidEmail: Bool {
        return ChatbotUtils.isValidEmail(self)
    }
    
    var isValidUserId: Bool {
        return ChatbotUtils.isValidUserId(self)
    }
}

extension UIButton {
    func applyChatbotStyle(
        backgroundColor: UIColor = .systemBlue,
        textColor: UIColor = .white,
        cornerRadius: CGFloat = 12,
        fontSize: CGFloat = 16,
        fontWeight: UIFont.Weight = .medium
    ) {
        self.backgroundColor = backgroundColor
        self.setTitleColor(textColor, for: .normal)
        self.layer.cornerRadius = cornerRadius
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }
}

extension ChatbotEvent {
    var formattedTimestamp: String {
        return ChatbotUtils.formatTimestamp(self.timestamp)
    }
    
    var jsonData: String? {
        guard let data = self.data else { return nil }
        return ChatbotUtils.dictionaryToJSON(data)
    }
}

// MARK: - Constants
struct ChatbotConstants {
    public static let minimumAPIKeyLength = 10
    public static let minimumUserIdLength = 3
    public static let defaultCornerRadius: CGFloat = 12
    public static let defaultFontSize: CGFloat = 16
    public static let defaultButtonHeight: CGFloat = 50
    public static let defaultButtonWidth: CGFloat = 200
    public static let isTestUser = "is_test_user"
    
    struct URLs {
        public static let debugBaseURL = "https://stage-api.robylon.ai"
        public static let productionBaseURL = "https://api.robylon.ai"
    }
    
    struct Colors {
        public static let primaryBlue = UIColor.systemBlue
        public static let secondaryGray = UIColor.systemGray
        public static let successGreen = UIColor.systemGreen
        public static let errorRed = UIColor.systemRed
        public static let warningOrange = UIColor.systemOrange
    }
    
    struct Fonts {
        public static let regular = UIFont.systemFont(ofSize: 16, weight: .regular)
        public static let medium = UIFont.systemFont(ofSize: 16, weight: .medium)
        public static let semibold = UIFont.systemFont(ofSize: 18, weight: .semibold)
        public static let bold = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    struct NotificationUserInfoKeys {
        public static let chatBotUrl = "chatBotUrl"
        public static let isInitialized = "isInitialized"
    }
}
