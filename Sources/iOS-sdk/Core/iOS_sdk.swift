// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit
import Foundation

// MARK: - iOS SDK Main Interface
@MainActor
public struct iOS_sdk {
    
    // MARK: - Chatbot Methods
    public static func initializeChatbot(config: ChatbotConfiguration) {
        Chatbot.shared.initialize(config: config)
    }
}
