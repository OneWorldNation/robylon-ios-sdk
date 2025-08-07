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
        
        // Extract brand config data
        let brandConfig = apiResponse.user?.org_info?.brand_config
        
        // Build event data in smaller parts
        var eventData: [String: Any] = [
            "apiKey": config.apiKey,
            "orgId": config.orgId ?? "",
            "userId": config.userId ?? "",
            "hasUserToken": config.userToken != nil,
            "hasUserProfile": config.userProfile != nil
        ]
        
        // Add brand config data
        var brandConfigData: [String: Any] = [
            "name": brandConfig?.name ?? "",
            "tagline": brandConfig?.tagline ?? "",
            "chatbotId": brandConfig?.chatbot_id ?? "",
            "launcherType": brandConfig?.launcher_type ?? "",
            "interfaceType": brandConfig?.interface_type ?? "",
            "enableBanner": brandConfig?.enable_banner ?? false,
            "enableMessageSound": brandConfig?.enable_message_sound ?? false,
            "enableUserFeedback": brandConfig?.enable_user_feedback ?? false,
            "streamAIResponses": brandConfig?.stream_ai_responses ?? false,
            "enableAIDisclaimer": brandConfig?.enable_ai_disclaimer ?? false
        ]
        
        // Add banner data
        brandConfigData["banner"] = [
            "title": brandConfig?.banner?.title ?? "",
            "description": brandConfig?.banner?.description ?? ""
        ]
        
        // Add colors data
        brandConfigData["colors"] = [
            "brandColor": brandConfig?.colors?.brand_color ?? "",
            "titleBarColor": brandConfig?.colors?.title_bar_color ?? ""
        ]
        
        // Add footer data
        brandConfigData["footer"] = [
            "footerLink": brandConfig?.footer?.footer_link ?? "",
            "footerLinkText": brandConfig?.footer?.footer_link_text ?? "",
            "showPoweredBy": brandConfig?.footer?.show_powered_by ?? false,
            "showCustomFooter": brandConfig?.footer?.show_custom_footer ?? false
        ]
        
        // Add launcher properties
        brandConfigData["launcherProperties"] = [
            "text": brandConfig?.launcher_properties?.text ?? ""
        ]
        
        // Add interface properties
        brandConfigData["interfaceProperties"] = [
            "position": brandConfig?.interface_properties?.position ?? "",
            "sideSpacing": brandConfig?.interface_properties?.side_spacing ?? 0,
            "bottomSpacing": brandConfig?.interface_properties?.bottom_spacing ?? 0
        ]
        
        // Add AI disclaimer
        brandConfigData["aiDisclaimer"] = [
            "message": brandConfig?.ai_disclaimer?.message ?? ""
        ]
        
        // Add images
        brandConfigData["images"] = [
            "launcherImageUrl": brandConfig?.images?.launcher_image_url?.url ?? "",
            "headerImageUrl": brandConfig?.images?.header_image_url?.url ?? "",
            "agentImageUrl": brandConfig?.images?.agent_image_url?.url ?? "",
            "bannerImageUrl": brandConfig?.images?.banner_image_url?.url ?? ""
        ]
        
        eventData["brandConfig"] = brandConfigData
        
        
        // Create and add custom button to parent view
        createAndAddCustomButton(to: config.parentView)
        
        ChatbotUtils.logSuccess("Chatbot button added successfully with API key: \(config.apiKey)")
    }
    
    private func createAndAddCustomButton(to parentView: UIView?) {
        guard let customConfig = customBottomConfig else {
            ChatbotUtils.logError("Custom button config not available")
            return
        }
        
        // Create the custom button
        let customButton = CustomButton(config: customConfig, callback: { [weak self] in
            self?.handleButtonCallback()
        })
        
        // Use provided parent view or fallback to root view controller
        let targetView: UIView
        if let parentView = parentView {
            targetView = parentView
        } else {
            guard let topViewController = UIApplication.shared.windows.first?.rootViewController else {
                ChatbotUtils.logError("No root view controller found and no parent view provided")
                return
            }
            targetView = topViewController.view
        }
        
        // Add button to the target view
        targetView.addSubview(customButton)
        
        // Position the button based on interface properties
        if let interfaceProps = customConfig.interfaceProperties {
            positionButtonInParentView(customButton, in: targetView, with: interfaceProps)
        } else {
            // Default positioning
            positionButtonInParentView(customButton, in: targetView, with: nil)
        }
        
        // Emit button loaded event
        if let config = configuration {
            let event = ChatbotEvent(type: .chatbotButtonLoaded)
            config.eventHandler?(event)
        }
        
        ChatbotUtils.logSuccess("Custom button created and added to parent view")
    }
    
    private func positionButtonInParentView(_ button: UIButton, in parentView: UIView, with interfaceProps: ChatbotAPIResponse.InterfaceProperties?) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Set position based on interface properties
        let position = interfaceProps?.position?.lowercased() ?? "right"
        let sideSpacing = CGFloat(interfaceProps?.side_spacing ?? 20)
        let bottomSpacing = CGFloat(interfaceProps?.bottom_spacing ?? 20)
        
        switch position {
        case "left":
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpacing)
            ])
        case "right":
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpacing)
            ])
        case "center":
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                button.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpacing)
            ])
        default:
            // Default to right position
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -sideSpacing),
                button.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -bottomSpacing)
            ])
        }
    }
    
    public func openChatbot() {
        guard isInitialized, let config = configuration else {
            print("Chatbot must be initialized before opening")
            return
        }
        
        // Create and present WebViewController
        let webVC = WebViewController()
        webVC.apiKey = config.apiKey
        webVC.userId = config.userId
        webVC.userToken = config.userToken
        webVC.userProfile = config.userProfile
        webVC.eventHandler = config.eventHandler
        
        self.webViewController = webVC
        
        // Present the WebViewController
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(webVC, animated: true) {
                // Emit chatbot opened event
                let openedEvent = ChatbotEvent(type: .chatbotOpened)
                config.eventHandler?(openedEvent)
            }
            
            // Set dismiss completion to clear reference
            webVC.dismissCompletion = { [weak self] in
                self?.webViewController = nil
                ChatbotUtils.logInfo("WebViewController reference cleared from Chatbot")
            }
        }
    }
    
    public func closeChatbot() {
        guard let webVC = webViewController else { return }
        
        // Clear the reference immediately to prevent retain cycles
        self.webViewController = nil
        
        webVC.dismiss(animated: true) { [weak self] in
            guard let self = self, let config = self.configuration else { return }
            
            // Emit chatbot closed event
            let event = ChatbotEvent(type: .chatbotClosed)
            config.eventHandler?(event)
            
            ChatbotUtils.logInfo("Chatbot closed and cleaned up")
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
    private func handleButtonCallback() {
        guard let config = configuration else { return }
        
        // Emit button clicked event
        let buttonEvent = ChatbotEvent(type: .chatbotButtonClicked)
        config.eventHandler?(buttonEvent)
        
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
