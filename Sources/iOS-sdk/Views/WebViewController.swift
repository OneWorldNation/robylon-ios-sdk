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
        let script = WKUserScript(source: logInjectionScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(script)
        userContentController.add(self, name: "jsLogger")
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
        addCloseButton()
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
        
        // Emit chatbot opened
        let event = ChatbotEvent(type: .chatbotOpened, data: [
            "url": urlString,
            "apiKey": apiKey,
            "userId": userId ?? "",
            "hasUserToken": userToken != nil
        ])
        eventHandler?(event)
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
        
        //console.log("✅ postMessage events scheduled");
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                ChatbotUtils.logError("Failed to inject postMessage events: \(error.localizedDescription)")
            } else {
                ChatbotUtils.logSuccess("postMessage events injected successfully")
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
        
        if message.name == "nativeLogger", let body = message.body as? String {
            if let data = body.data(using: .utf8) {
//                do {
//                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("✅ Parsed Dictionary: \(jsonDict)")
//                        if jsonDict["name"] as? String == "openFrame" {
//                            print("🎯 openFrame message received")
//                        } else if jsonDict["name"] as? String == "registerUserId" {
//                            print("🎯 registerUserId message received")
//                        }
//                    }
//                } catch {
//                    print("❌ JSON parsing failed: \(error)")
//                }
            }
        }
        
        if message.name == "jsLogger", let body = message.body as? String {
            print("🪵 JavaScript Log: \(body)")
        }
        
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
}

