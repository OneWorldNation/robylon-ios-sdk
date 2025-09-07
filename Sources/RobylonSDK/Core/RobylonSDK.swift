// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit
import Foundation

/// Main entry point for the iOS Chatbot SDK.
/// This struct provides a simple interface to initialize and manage the chatbot functionality.
/// 
/// ## Usage Example:
/// ```swift
/// // Initialize the chatbot with configuration
/// let config = ChatbotConfiguration(
///     apiKey: "your-api-key",
///     userId: "user123",
///     userToken: "auth-token",
///     userProfile: ChatbotUserProfile(name: "John", email: "john@example.com"),
///     debugMode: false,
///     eventHandler: { event in
///         print("Chatbot event: \(event.type.rawValue)")
///     },
///     parentView: self.view,
///     presetationStyle: .default
/// )
/// 
/// RobylonSDK.initializeChatbot(config: config)
/// ```
@MainActor
public struct RobylonSDK {
    
    /// Initializes the chatbot with the provided configuration.
    /// This method must be called before using any other chatbot functionality.
    /// 
    /// ## Parameters:
    /// - `config`: A `ChatbotConfiguration` object containing all necessary parameters for chatbot initialization
    /// 
    /// ## Important Notes:
    /// - The chatbot uses a singleton pattern, so this method should only be called once per app session
    /// - If called multiple times, subsequent calls will be ignored
    /// - The chatbot will automatically create and add a custom button to the specified parent view
    /// - API calls will be made to validate the chatbot configuration
    /// 
    /// ## Configuration Options:
    /// - **apiKey**: Required API key for authentication
    /// - **userId**: Optional user identifier (auto-generated if not provided)
    /// - **userToken**: Optional authentication token
    /// - **userProfile**: Optional user profile information
    /// - **debugMode**: Set to `true` for staging environment, `false` for production
    /// - **eventHandler**: Callback for receiving chatbot events
    /// - **parentView**: UIView where the chatbot button will be added
    /// - **presetationStyle**: How the chatbot interface should be presented
    /// 
    /// ## Example:
    /// ```swift
    /// let config = ChatbotConfiguration(
    ///     apiKey: "your-api-key",
    ///     debugMode: true, // Use staging environment
    ///     eventHandler: { event in
    ///         switch event.type {
    ///         case .chatbotButtonLoaded:
    ///             print("Button loaded successfully")
    ///         case .chatbotOpened:
    ///             print("Chatbot opened")
    ///         case .chatbotClosed:
    ///             print("Chatbot closed")
    ///         default:
    ///             break
    ///         }
    ///     },
    ///     parentView: self.view
    /// )
    /// 
    /// RobylonSDK.initializeChatbot(config: config)
    /// ```
    public static func initializeChatbot(config: ChatbotConfiguration) {
        Chatbot.shared.initialize(config: config)
    }
    
    /// Opens the chatbot directly with the provided configuration.
    /// If the chatbot is not initialized, this method will automatically initialize it first.
    /// 
    /// ## Parameters:
    /// - `config`: A `ChatbotConfiguration` object containing all necessary parameters
    /// 
    /// ## Important Notes:
    /// - This method will automatically initialize the chatbot if it hasn't been initialized yet
    /// - The chatbot will wait for initialization to complete before opening
    /// - If initialization fails, an error event will be emitted through the eventHandler
    /// 
    /// ## Example:
    /// ```swift
    /// let config = ChatbotConfiguration(
    ///     apiKey: "your-api-key",
    ///     eventHandler: { event in
    ///         print("Chatbot event: \(event.type.rawValue)")
    ///     },
    ///     parentView: self.view
    /// )
    /// 
    /// RobylonSDK.openChatbot(config: config)
    /// ```
    public static func openChatbot(config: ChatbotConfiguration) {
        Chatbot.shared.openChatbotWithConfig(config)
    }
    
    /// Destroys the chatbot instance, clearing all resources and resetting state.
    /// This method will completely reset the chatbot to its initial state.
    /// 
    /// ## What it does:
    /// - Clears and destroys the WebView instance
    /// - Resets the initialization state
    /// - Clears the configuration
    /// - Clears the custom button configuration
    /// 
    /// ## Important Notes:
    /// - This will completely reset the chatbot to its initial state
    /// - Any existing WebView will be dismissed and destroyed
    /// - The chatbot will need to be re-initialized before use
    /// - This is useful for memory management or when switching configurations
    /// 
    /// ## Example:
    /// ```swift
    /// // Destroy the chatbot instance
    /// RobylonSDK.destroyChatbot()
    /// 
    /// // Later, re-initialize with new configuration
    /// let newConfig = ChatbotConfiguration(apiKey: "new-key", ...)
    /// RobylonSDK.initializeChatbot(config: newConfig)
    /// ```
    public static func destroyChatbot() {
        Chatbot.shared.destroy()
    }
    
}
