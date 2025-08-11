//
//  WebViewController.swift
//  iOS-sdk
//
//  Created by Aadesh Maheshwari on 02/08/25.
//
import UIKit
import WebKit

@MainActor
public class WebViewController: UIViewController {
    
    // MARK: - Properties
    public var apiKey: String = ""
    public var userId: String = UUID().uuidString
    public var userToken: String?
    public var userProfile: UserProfile?
    public var eventHandler: ChatbotEventHandler?
    public var dismissCompletion: (() -> Void)?
    
    private var webView: WKWebView!

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadChatbotURL()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If this is a dismissal (not a push), clean up
        if isBeingDismissed {
            cleanupWebView()
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // If this is a dismissal, clear references
        if isBeingDismissed {
            // Call dismiss completion and clear it
            dismissCompletion?()
            dismissCompletion = nil
            
            // Clear references to prevent retain cycles
            eventHandler = nil
            webView = nil
            
            ChatbotUtils.logInfo("WebViewController dismissed and cleaned up")
        }
    }
    
    // MARK: - Setup
    private func setupWebView() {
        // Configure WKWebView
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Add user content controller for JavaScript communication
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "chatbotHandler")
        
        // Inject JavaScript to override console.log
        let logInjectionScript = """
        (function() {
            var oldLog = console.log;
            console.log = function(message) {
                window.webkit.messageHandlers.jsLogger.postMessage("LOG: " + message);
                oldLog.apply(console, arguments);
            };
            var oldError = console.error;
            console.error = function(message) {
                window.webkit.messageHandlers.jsLogger.postMessage("ERROR: " + message);
                oldError.apply(console, arguments);
            };
        })();
        """
        #if DEBUG
//            let script = WKUserScript(source: logInjectionScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
//            userContentController.addUserScript(script)
//            userContentController.add(self, name: "jsLogger")
        #endif
        configuration.userContentController = userContentController
        
        // Create web view
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.bounces = false
        
        // Add to view hierarchy
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadChatbotURL() {
        // Construct URL with chatbot ID
        let baseURL = "https://staging.d2s3wsqyyond1h.amplifyapp.com/chatbot-plugin"
        let urlString = "\(baseURL)?id=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            ChatbotUtils.logError("Invalid chatbot URL: \(urlString)")
            return
        }
        
        ChatbotUtils.logInfo("Loading chatbot URL: \(urlString)")
        
        // Create request with headers
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add user data if available
        request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        
        if let userToken = userToken, !userToken.isEmpty {
            request.setValue(userToken, forHTTPHeaderField: "X-User-Token")
        }
        
        // Load the request
        webView.load(request)
    }
    
    private func closeButtonTapped() {
        // Remove all message handlers to prevent memory leaks
        cleanupWebView()
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // Call dismiss completion and clear it
            self.dismissCompletion?()
            self.dismissCompletion = nil
            
            // Clear references to prevent retain cycles
            self.eventHandler = nil
            self.webView = nil
        }
    }
    
    // MARK: - Cleanup Methods
    private func cleanupWebView() {
        guard let webView = webView else { return }
        
        // Remove all message handlers
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        
        // Stop loading and clear navigation delegate
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        
        // Clear the web view content
        webView.loadHTMLString("", baseURL: nil)
        
        ChatbotUtils.logInfo("WebView cleanup completed")
    }
    
    // MARK: - Deinit
    deinit {
        ChatbotUtils.logInfo("WebViewController deallocated")
    }
    
    // MARK: - JavaScript Communication
    private func injectPostMessageEvents() {
        let systemInfo = getSystemInfo()
        let userId = UUID().uuidString
        let userToken = self.userToken?.isEmpty == false ? self.userToken! : nil
        
        let script = """
        // Add window.postMessage listener to capture responses
        window.addEventListener('message', function(event) {
            // Forward the message to native app
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.chatbotHandler) {
                window.webkit.messageHandlers.chatbotHandler.postMessage({
                    type: "postMessageResponse",
                    data: event.data,
                    origin: event.origin,
                    source: event.source ? "external" : "internal",
                    timestamp: Date.now()
                });
            }
        });
        
        // Send initial events
        window.dispatchEvent(new MessageEvent('message', { data: { name: 'openFrame', domain: 'app-domain.com' } }))
        
        window.dispatchEvent(new MessageEvent('message', {
            data: {
                name: "registerUserId",
                action: "registerUserId",
                data: {
                    userId: "\(userId)",
                    token: undefined,
                    userProfile: {
                        name: "\(userProfile?.name ?? "")",
                        email: "\(userProfile?.email ?? "")",
                        platform: "\(systemInfo.platform)",
                        os: "\(systemInfo.os)",
                        browser: "\(systemInfo.browser)",
                        sdk_version: "\(systemInfo.sdk_version)",
                        device: "\(systemInfo.device)",
                        screen_size: "\(systemInfo.screen_size)"
                    }
                }
            }
        }))
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                ChatbotUtils.logError("Failed to inject postMessage events: \(error.localizedDescription)")
            }
        }
    }
    
    private func getSystemInfo() -> (platform: String, os: String, browser: String, sdk_version: String, device: String, screen_size: String) {
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
        case .vision:
            device = "Vision"
        @unknown default:
            device = "Unknown"
        }
        
        // Get screen size
        let screen = UIScreen.main.bounds
        let screen_size = "\(Int(screen.width))x\(Int(screen.height))"
        
        return (platform, os, browser, sdk_version, device, screen_size)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ChatbotUtils.logSuccess("Chatbot web page loaded successfully")
        
        // Wait a bit for the page to fully load, then inject postMessage events
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.injectPostMessageEvents()
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ChatbotUtils.logError("Failed to load chatbot web page: \(error.localizedDescription)")
        
        // Emit error event
        let event = ChatbotEvent(type: .chatInitializationFailed, data: ["error": error.localizedDescription])
        eventHandler?(event)
    }
}

// MARK: - WKUIDelegate
extension WebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle new window requests by loading in the same web view
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        ChatbotUtils.logInfo("Received message from JavaScript: \(message.name) - \(message.body)")
        
        if message.name == "jsLogger", let body = message.body as? String {
            print("🪵 JavaScript Log: \(body)")
        }
        
        // Handle postMessage responses
        if message.name == "chatbotHandler",
           let body = message.body as? [String: Any],
           let type = body["type"] as? String,
           type == "postMessageResponse" {
        
            handlePostMessageResponse(body)
            return
        }
    }
    
    // MARK: - PostMessage Response Handling
    private func handlePostMessageResponse(_ response: [String: Any]) {
        guard let data = response["data"] else {
            print("📨 No data in postMessage response")
            return
        }
        // Handle different types of postMessage responses
        if let messageData = data as? [String: Any] {
            handleStructuredPostMessage(messageData)
        } else {
            print("📨 Unknown postMessage data type: \(type(of: data))")
        }
    }
    
    private func handleStructuredPostMessage(_ data: [String: Any]) {
        // Handle structured message data
        if let type = data["type"] as? String {
            switch type {
            case "CHATBOT_CLOSED":
                // Record analytics event
                if let config = Chatbot.shared.getConfiguration() {
                    ChatbotAnalyticsService.shared.recordEvent(
                        eventType: .chatbotClosed,
                        config: config,
                        additionalData: data
                    )
                }
                
                // Emit chatbot closed event
                let event = ChatbotEvent(type: .chatbotClosed, data: data)
                self.eventHandler?(event)
                closeButtonTapped()
                
            case "CHAT_INITIALIZED":
                // Record analytics event
                if let config = Chatbot.shared.getConfiguration() {
                    ChatbotAnalyticsService.shared.recordEvent(
                        eventType: .chatInitialized,
                        config: config,
                        additionalData: data
                    )
                }
                
                let event = ChatbotEvent(type: .chatInitialized, data: data)
                eventHandler?(event)
                
            case "CHATBOT_LOADED":
                // Record analytics event
                if let config = Chatbot.shared.getConfiguration() {
                    ChatbotAnalyticsService.shared.recordEvent(
                        eventType: .chatbotLoaded,
                        config: config,
                        additionalData: data
                    )
                }
                
                let event = ChatbotEvent(type: .chatbotLoaded, data: data)
                eventHandler?(event)
                
            case "CHAT_INITIALIZATION_FAILED":
                // Record analytics event
                if let config = Chatbot.shared.getConfiguration() {
                    ChatbotAnalyticsService.shared.recordEvent(
                        eventType: .chatInitializationFailed,
                        config: config,
                        additionalData: data
                    )
                }
                
                let event = ChatbotEvent(type: .chatInitializationFailed, data: data)
                eventHandler?(event)
                
            case "SESSION_REFRESHED":
                // Record analytics event
                if let config = Chatbot.shared.getConfiguration() {
                    ChatbotAnalyticsService.shared.recordEvent(
                        eventType: .sessionRefreshed,
                        config: config,
                        additionalData: data
                    )
                }
                
                let event = ChatbotEvent(type: .sessionRefreshed, data: data)
                eventHandler?(event)
                
                    default:
                ChatbotUtils.logWarning("📨 Unknown structured message type: \(type)")
            }
        } else {
            ChatbotUtils.logInfo("📨 Structured message not to be processed")
        }
    }
}


