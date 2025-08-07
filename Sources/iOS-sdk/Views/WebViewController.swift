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
    private var webView: WKWebView!
    public var apiKey: String?
    public var userId: String?
    public var userToken: String?
    public var userProfile: UserProfile?
    public var eventHandler: ChatbotEventHandler?
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadChatbotURL()
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
        
        // Add close button
//        addCloseButton()
    }
    
    private func loadChatbotURL() {
        guard let apiKey = apiKey else {
            ChatbotUtils.logError("API key is required to load chatbot URL")
            return
        }
        
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
        if let userId = userId, !userId.isEmpty {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        if let userToken = userToken, !userToken.isEmpty {
            request.setValue(userToken, forHTTPHeaderField: "X-User-Token")
        }
        
        // Load the request
        webView.load(request)
    }
    
    private func addCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // Emit chatbot closed event
            let event = ChatbotEvent(type: .chatbotClosed)
            self.eventHandler?(event)
        }
    }
    
    // MARK: - JavaScript Communication
    private func injectPostMessageEvents() {
        let systemInfo = getSystemInfo()
        let userId = UUID().uuidString
        let userToken = self.userToken?.isEmpty == false ? self.userToken! : nil
        
        let script = """
        // Add window.postMessage listener to capture responses
        window.addEventListener('message', function(event) {
            console.log("📨 window.postMessage received:", event.data);
            
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
        
        console.log("✅ Android.handlePayload, chatOperations, and postMessage listener setup complete");
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                ChatbotUtils.logError("Failed to inject postMessage events: \(error.localizedDescription)")
            } else {
                ChatbotUtils.logSuccess("postMessage events and Android.handlePayload injected successfully")
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
        
        print("Received message from JavaScript: \(message.name) - \(message.body)")
        
        if message.name == "jsLogger", let body = message.body as? String {
            print("🪵 JavaScript Log: \(body)")
        }
        
        // Handle postMessage responses
        if message.name == "chatbotHandler",
           let body = message.body as? [String: Any],
           let type = body["type"] as? String,
           type == "postMessageResponse" {
            
            print("📨 Processing postMessage response")
            handlePostMessageResponse(body)
            return
        }
        
        // Handle Android.handlePayload style events
        if message.name == "chatbotHandler",
           let body = message.body as? [String: Any],
           let operation = body["operation"] as? String {
            
            print("🔧 Handling operation: \(operation)")
            handleOperation(operation, data: body)
            return
        }
        
        // Handle traditional message events
        guard message.name == "chatbotHandler",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else {
            return
        }
        
        let data = body["data"] as? [String: Any]
        
        ChatbotUtils.logInfo("Received JavaScript message: \(type)")
        
        // Handle different message types from web content
        switch type {
        case "close":
            // Web content requested to close the chatbot
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                let event = ChatbotEvent(type: .chatbotClosed, data: data)
                self.eventHandler?(event)
            }
            
        case "sessionRefreshed":
            // Web content refreshed the session
            let event = ChatbotEvent(type: .sessionRefreshed, data: data)
            eventHandler?(event)
            
        case "chatMoved":
            // Web content moved the chat (internal event)
            let event = ChatbotEvent(type: .chatbotOpened, data: data)
            eventHandler?(event)
            
        default:
            // Handle other custom events
            ChatbotUtils.logInfo("Unhandled JavaScript event: \(type)")
        }
    }
    
    // MARK: - PostMessage Response Handling
    private func handlePostMessageResponse(_ response: [String: Any]) {
        guard let data = response["data"] else {
            print("📨 No data in postMessage response")
            return
        }
        
        let origin = response["origin"] as? String ?? "unknown"
        let source = response["source"] as? String ?? "unknown"
        let timestamp = response["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970
        
        print("📨 PostMessage Response Details:")
        print("📨 Origin: \(origin)")
        print("📨 Source: \(source)")
        print("📨 Timestamp: \(timestamp)")
        print("📨 Data: \(data)")
        
        // Handle different types of postMessage responses
        if let messageData = data as? [String: Any] {
            handleStructuredPostMessage(messageData, origin: origin, source: source, timestamp: timestamp)
        } else if let messageString = data as? String {
            handleStringPostMessage(messageString, origin: origin, source: source, timestamp: timestamp)
        } else {
            print("📨 Unknown postMessage data type: \(type(of: data))")
        }
    }
    
    private func handleStructuredPostMessage(_ data: [String: Any], origin: String, source: String, timestamp: TimeInterval) {
        // Handle structured message data
        if let name = data["name"] as? String {
            print("📨 Structured message with name: \(name)")
            
            switch name {
            case "openFrame":
                print("📨 openFrame response received")
                let event = ChatbotEvent(type: .chatbotAppReady, data: data)
                eventHandler?(event)
                
            case "registerUserId":
                print("📨 registerUserId response received")
                if let responseData = data["data"] as? [String: Any] {
                    print("📨 User registration response: \(responseData)")
                }
                let event = ChatbotEvent(type: .chatInitialized, data: data)
                eventHandler?(event)
                
            case "chatResponse":
                print("📨 Chat response received")
                if let chatData = data["data"] as? [String: Any] {
                    print("📨 Chat data: \(chatData)")
                }
                
            case "error":
                print("📨 Error response received")
                if let errorData = data["data"] as? [String: Any] {
                    print("📨 Error data: \(errorData)")
                    let event = ChatbotEvent(type: .chatInitializationFailed, data: errorData)
                    eventHandler?(event)
                }
                
            default:
                print("📨 Unknown structured message name: \(name)")
                // Emit custom event for unknown messages
                let event = ChatbotEvent(type: .chatbotLoaded, data: data)
                eventHandler?(event)
            }
        } else {
            print("📨 Structured message without name: \(data)")
        }
    }
    
    private func handleStringPostMessage(_ message: String, origin: String, source: String, timestamp: TimeInterval) {
        print("📨 String message received: \(message)")
        
        // Try to parse as JSON
        if let data = message.data(using: .utf8) {
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("📨 Parsed JSON from string message: \(jsonData)")
                    handleStructuredPostMessage(jsonData, origin: origin, source: source, timestamp: timestamp)
                } else {
                    print("📨 String message is not valid JSON")
                    // Handle as plain text message
                    let event = ChatbotEvent(type: .chatbotLoaded, data: ["message": message])
                    eventHandler?(event)
                }
            } catch {
                print("📨 Failed to parse string message as JSON: \(error)")
                // Handle as plain text message
                let event = ChatbotEvent(type: .chatbotLoaded, data: ["message": message])
                eventHandler?(event)
            }
        }
    }
    
    // MARK: - Operation Handling
    private func handleOperation(_ operation: String, data: [String: Any]) {
        switch operation {
        case "chat.close":
            print("🔧 Operation: chat.close - Closing chatbot")
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                let event = ChatbotEvent(type: .chatbotClosed, data: data)
                self.eventHandler?(event)
            }
            
        case "chat.open":
            print("🔧 Operation: chat.open - Opening chatbot")
            let event = ChatbotEvent(type: .chatbotOpened, data: data)
            eventHandler?(event)
            
        case "chat.refresh":
            print("🔧 Operation: chat.refresh - Refreshing session")
            let event = ChatbotEvent(type: .sessionRefreshed, data: data)
            eventHandler?(event)
            
        case "chat.move":
            print("🔧 Operation: chat.move - Moving chat")
            let event = ChatbotEvent(type: .chatbotOpened, data: data)
            eventHandler?(event)
            
        case "chat.ready":
            print("🔧 Operation: chat.ready - Chat is ready")
            let event = ChatbotEvent(type: .chatbotAppReady, data: data)
            eventHandler?(event)
            
        case "chat.loaded":
            print("🔧 Operation: chat.loaded - Chat loaded")
            let event = ChatbotEvent(type: .chatbotLoaded, data: data)
            eventHandler?(event)
            
        case "chat.error":
            print("🔧 Operation: chat.error - Chat error occurred")
            let event = ChatbotEvent(type: .chatInitializationFailed, data: data)
            eventHandler?(event)
            
        case "user.register":
            print("🔧 Operation: user.register - User registration")
            if let userData = data["userData"] as? [String: Any] {
                print("🔧 User data: \(userData)")
            }
            
        case "message.send":
            print("🔧 Operation: message.send - Message sent")
            if let messageData = data["message"] as? [String: Any] {
                print("🔧 Message data: \(messageData)")
            }
            
        case "message.receive":
            print("🔧 Operation: message.receive - Message received")
            if let messageData = data["message"] as? [String: Any] {
                print("🔧 Message data: \(messageData)")
            }
            
        default:
            print("🔧 Unhandled operation: \(operation)")
            ChatbotUtils.logInfo("Unhandled operation: \(operation) with data: \(data)")
        }
    }
}


