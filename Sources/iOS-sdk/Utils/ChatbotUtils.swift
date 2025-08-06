import Foundation
import UIKit

// MARK: - Chatbot Utilities
public struct ChatbotUtils {
    
    // MARK: - Validation
    public static func isValidAPIKey(_ apiKey: String) -> Bool {
        return !apiKey.isEmpty && apiKey.count >= 10
    }
    
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    public static func isValidUserId(_ userId: String) -> Bool {
        return !userId.isEmpty && userId.count >= 3
    }
    
    // MARK: - UI Helpers
    @MainActor
    public static func createStyledButton(
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
    public static func logInfo(_ message: String) {
        print("ℹ️ [Chatbot] \(message)")
    }
    
    public static func logWarning(_ message: String) {
        print("⚠️ [Chatbot] \(message)")
    }
    
    public static func logError(_ message: String) {
        print("❌ [Chatbot] \(message)")
    }
    
    public static func logSuccess(_ message: String) {
        print("✅ [Chatbot] \(message)")
    }
    
    // MARK: - Date Formatting
    public static func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - JSON Helpers
    public static func dictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    public static func jsonToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}

// MARK: - Extensions
extension String {
    public var isValidAPIKey: Bool {
        return ChatbotUtils.isValidAPIKey(self)
    }
    
    public var isValidEmail: Bool {
        return ChatbotUtils.isValidEmail(self)
    }
    
    public var isValidUserId: Bool {
        return ChatbotUtils.isValidUserId(self)
    }
}

extension UIButton {
    public func applyChatbotStyle(
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
    public var formattedTimestamp: String {
        return ChatbotUtils.formatTimestamp(self.timestamp)
    }
    
    public var jsonData: String? {
        guard let data = self.data else { return nil }
        return ChatbotUtils.dictionaryToJSON(data)
    }
}

// MARK: - Constants
public struct ChatbotConstants {
    public static let minimumAPIKeyLength = 10
    public static let minimumUserIdLength = 3
    public static let defaultCornerRadius: CGFloat = 12
    public static let defaultFontSize: CGFloat = 16
    public static let defaultButtonHeight: CGFloat = 50
    public static let defaultButtonWidth: CGFloat = 200
    
    public struct Colors {
        public static let primaryBlue = UIColor.systemBlue
        public static let secondaryGray = UIColor.systemGray
        public static let successGreen = UIColor.systemGreen
        public static let errorRed = UIColor.systemRed
        public static let warningOrange = UIColor.systemOrange
    }
    
    public struct Fonts {
        public static let regular = UIFont.systemFont(ofSize: 16, weight: .regular)
        public static let medium = UIFont.systemFont(ofSize: 16, weight: .medium)
        public static let semibold = UIFont.systemFont(ofSize: 18, weight: .semibold)
        public static let bold = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
} 