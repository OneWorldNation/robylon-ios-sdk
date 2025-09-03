//
//  WebViewController.swift
//  RobylonSDK
//
//  Created by Aadesh Maheshwari on 02/08/25.
//
import UIKit
import WebKit

@MainActor
final class WebViewController: UIViewController {
    
    // MARK: - Properties
    private let apiKey: String
    private let url: String
    private let userId: String
    private let userToken: String?
    var userProfile: UserProfile?
    var eventHandler: ChatbotEventHandler?
    var dismissCompletion: (() -> Void)?
    
    private var webView: WKWebView!
    private var isInitialized = false
    private var chatbotObserver: NSObjectProtocol?

    init(
        apiKey: String,
        url: String,
        userId: String = UUID().uuidString,
        userToken: String? = nil,
        userProfile: UserProfile? = nil,
        eventHandler: ChatbotEventHandler? = nil,
        dismissCompletion: (() -> Void)? = nil
    ) {
        self.apiKey = apiKey
        self.url = url
        self.userId = userId
        self.userToken = userToken
        self.userProfile = userProfile
        self.eventHandler = eventHandler
        self.dismissCompletion = dismissCompletion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
        // Check if chatbot is initialized before loading URL
        if Chatbot.shared.isInitialized {
            // Only load URL if not already loaded
            if !isInitialized {
                loadChatbotURL()
            }
        } else {
            // Chatbot not initialized, set up observer and show waiting message
            setupChatbotObserver()
            handleUninitializedChatbot()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add listeners when view appears
        if isInitialized {
            addMessageListeners()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove listeners when view disappears
        removeMessageListeners()
        
        // Remove chatbot observer
        removeChatbotObserver()
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
        let urlString = url
        
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
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // Call dismiss completion and clear it
            self.dismissCompletion?()
        }
    }
    
     // MARK: - Message Listeners Management
    private func addMessageListeners() {
        guard !isInitialized else { return }
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
            } else {
                self.isInitialized = true
                ChatbotUtils.logInfo("Message listeners added successfully")
            }
        }
    }
    
    private func removeMessageListeners() {
        let script = """
        // Remove window.postMessage listener
        if (window.removeEventListener) {
            window.removeEventListener('message', window.chatbotMessageListener);
        }
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                ChatbotUtils.logError("Failed to remove message listeners: \(error.localizedDescription)")
            } else {
                ChatbotUtils.logInfo("Message listeners removed successfully")
            }
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
        
        ChatbotUtils.logInfo("WebView cleanup completed")
    }
    
    // MARK: - Deinit
    deinit {
        ChatbotUtils.logInfo("WebViewController deallocated")
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
        @unknown default:
            device = "Unknown"
        }
        
        // Get screen size
        let screen = UIScreen.main.bounds
        let screen_size = "\(Int(screen.width))x\(Int(screen.height))"
        
        return (platform, os, browser, sdk_version, device, screen_size)
    }
    
    // MARK: - Chatbot Observer Management
    private func setupChatbotObserver() {
        // Remove any existing observer first
        removeChatbotObserver()
        
        // Set up notification observer for chatbot initialization status changes
        chatbotObserver = NotificationCenter.default.addObserver(
            forName: .chatbotInitializationStatusChanged,
            object: Chatbot.shared,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let isInitialized = userInfo["isInitialized"] as? Bool else {
                return
            }
            
            if isInitialized {
                // Chatbot is now initialized, proceed with loading
                self.removeChatbotObserver()
                self.loadChatbotURL()
            }
        }
    }
    
    private func removeChatbotObserver() {
        if let observer = chatbotObserver {
            NotificationCenter.default.removeObserver(observer)
            chatbotObserver = nil
        }
    }
    
    // MARK: - Initialization Handling
    private func handleUninitializedChatbot() {
        // Show simple waiting message since KVO will handle the rest
        let alert = UIAlertController(
            title: "Chatbot Initializing",
            message: "The chatbot is being set up. It will automatically open when ready.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ChatbotUtils.logSuccess("Chatbot web page loaded successfully")
        
        // Wait a bit for the page to fully load, then inject postMessage events
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addMessageListeners()
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
    internal func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle new window requests by loading in the same web view
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        ChatbotUtils.logInfo("Received message from JavaScript: \(message.name) - \(message.body)")
        
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


