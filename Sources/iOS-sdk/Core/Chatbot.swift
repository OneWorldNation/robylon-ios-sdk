import UIKit
import Foundation

// MARK: - Chatbot Singleton
@MainActor
public class Chatbot {
    public static let shared = Chatbot()
    
    // MARK: - Properties
    private var configuration: ChatbotConfiguration?
    private var isInitialized = false
    private var webViewController: WebViewController?
    private var customBottomConfig: CustomButtonConfig?
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    public func initialize(config: ChatbotConfiguration) {
        guard !isInitialized else {
            print("Chatbot is already initialized")
            return
        }
        
        guard !config.apiKey.isEmpty else {
            let event = ChatbotEvent(type: .chatInitializationFailed, data: ["error": "API key is required"])
            config.eventHandler?(event)
            return
        }
        
        // Make API call to validate chatbot
        ChatbotNetworkService.shared.initialiseChatbot(
            config: config
        ) { [weak self] result in
            switch result {
            case .success(let apiResponse):
                self?.completeInitialization(with: config, apiResponse: apiResponse)
            case .failure(let error):
                let event = ChatbotEvent(
                    type: .chatInitializationFailed,
                    data: ["error": error.localizedDescription]
                )
                config.eventHandler?(event)
                ChatbotUtils.logError("Chatbot initialization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func completeInitialization(with config: ChatbotConfiguration, apiResponse: ChatbotAPIResponse) {
        self.configuration = config
        self.isInitialized = true
        
        // Create CustomBottomConfig from API response
        self.customBottomConfig = CustomButtonConfig.from(apiResponse: apiResponse)
        
    }
    
    public func createButton() -> UIButton? {
        guard isInitialized, let config = configuration else {
            print("Chatbot must be initialized before creating button")
            return nil
        }
        
        if let customConfig = customBottomConfig {
            let button = CustomButton(config: customConfig) { [weak self] message in
                self?.handleButtonCallback(message)
            }
            
            // Position the button based on parent frame and interface properties
            if let parentFrame = config.parentFrame, let interfaceProps = customConfig.interfaceProperties {
                positionButton(button, in: parentFrame, with: interfaceProps)
            }
            
            // Emit button loaded event
            let event = ChatbotEvent(type: .chatbotButtonLoaded)
            config.eventHandler?(event)
            
            return button
        } else {
            // Fallback to default button
            let button = CustomButton { [weak self] message in
                self?.handleButtonCallback(message)
            }
            
            // Emit button loaded event
            let event = ChatbotEvent(type: .chatbotButtonLoaded)
            config.eventHandler?(event)
            
            return button
        }
    }
    
    private func positionButton(_ button: UIButton, in parentFrame: CGRect, with interfaceProps: ChatbotAPIResponse.InterfaceProperties) {
        guard let parentView = button.superview else { return }
        
        // Remove existing constraints
        button.removeFromSuperview()
        parentView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Set position based on interface properties
        let position = interfaceProps.position?.lowercased() ?? "right"
        let sideSpacing = CGFloat(interfaceProps.side_spacing ?? 20)
        let bottomSpacing = CGFloat(interfaceProps.bottom_spacing ?? 20)
        
        switch position {
        case "left":
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -bottomSpacing)
            ])
        case "right":
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -bottomSpacing)
            ])
        case "center":
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                button.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -bottomSpacing)
            ])
        default:
            // Default to right position
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -bottomSpacing)
            ])
        }
    }
    
    public func openChatbot() {
        guard isInitialized, let config = configuration else {
            print("Chatbot must be initialized before opening")
            return
        }
        
        // Emit button clicked event
        let buttonEvent = ChatbotEvent(type: .chatbotButtonClicked)
        config.eventHandler?(buttonEvent)
        
        // Create and present WebViewController
        let webVC = WebViewController()
        webVC.apiKey = config.apiKey
        webVC.userId = config.userId
        webVC.userToken = config.userToken
        webVC.userProfile = config.userProfile
        webVC.eventHandler = config.eventHandler
        
        self.webViewController = webVC
        
        // Emit chatbot opened event
        let openedEvent = ChatbotEvent(type: .chatbotOpened)
        config.eventHandler?(openedEvent)
        
        // Present the WebViewController
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(webVC, animated: true) {
                // Emit app ready event after presentation
                let appReadyEvent = ChatbotEvent(type: .chatbotAppReady)
                config.eventHandler?(appReadyEvent)
            }
        }
    }
    
    public func closeChatbot() {
        guard let webVC = webViewController else { return }
        
        webVC.dismiss(animated: true) { [weak self] in
            guard let self = self, let config = self.configuration else { return }
            
            // Emit chatbot closed event
            let event = ChatbotEvent(type: .chatbotClosed)
            config.eventHandler?(event)
            
            self.webViewController = nil
        }
    }
    
    public func refreshSession() {
        guard isInitialized, let config = configuration else { return }
        
        let event = ChatbotEvent(type: .sessionRefreshed)
        config.eventHandler?(event)
    }
    
    public func isChatbotOpen() -> Bool {
        return webViewController != nil
    }
    
    // MARK: - Private Methods
    private func handleButtonCallback(_ message: String) {
        guard let config = configuration else { return }
        
        // Handle any button callbacks here
        print("Button callback received: \(message)")
        
        // Open chatbot when button is tapped
        openChatbot()
    }
    
    // MARK: - Utility Methods
    public func getConfiguration() -> ChatbotConfiguration? {
        return configuration
    }
    
    public func getCustomBottomConfig() -> CustomButtonConfig? {
        return customBottomConfig
    }
    
    public func reset() {
        configuration = nil
        isInitialized = false
        webViewController = nil
        customBottomConfig = nil
    }
} 
