//
//  WebViewController.swift
//  iOS-sdk
//
//  Created by Aadesh Maheshwari on 02/08/25.
//
import UIKit
import WebKit

final class WebViewController: UIViewController, WKScriptMessageHandler {
    
    var onJSCallback: ((String) -> Void)?
    var eventHandler: ChatbotEventHandler?
    
    // Chatbot configuration properties
    var apiKey: String = ""
    var userId: String?
    var userToken: String?
    var userProfile: UserProfile?
    
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadChatbotHTML()
        
        // Emit chatbot loaded event
        let event = ChatbotEvent(type: .chatbotLoaded)
        eventHandler?(event)
    }

    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "iOSListener")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadChatbotHTML() {
        // Create user profile JSON
//        let userProfileJson = ""
//        let userProfileString = String(data: try! JSONSerialization.data(withJSONObject: userProfileJson), encoding: .utf8) ?? "{}"
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    margin: 0; 
                    padding: 20px; 
                    background: #f5f5f5;
                }
                .chatbot-container {
                    background: white;
                    border-radius: 12px;
                    padding: 20px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    max-width: 600px;
                    margin: 0 auto;
                }
                .header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                    padding-bottom: 15px;
                    border-bottom: 1px solid #eee;
                }
                .close-btn {
                    background: #ff4444;
                    color: white;
                    border: none;
                    padding: 8px 16px;
                    border-radius: 6px;
                    cursor: pointer;
                }
                .chat-area {
                    min-height: 300px;
                    border: 1px solid #ddd;
                    border-radius: 8px;
                    padding: 15px;
                    margin-bottom: 15px;
                    background: #fafafa;
                }
                .input-area {
                    display: flex;
                    gap: 10px;
                }
                .message-input {
                    flex: 1;
                    padding: 12px;
                    border: 1px solid #ddd;
                    border-radius: 6px;
                    font-size: 16px;
                }
                .send-btn {
                    background: #007AFF;
                    color: white;
                    border: none;
                    padding: 12px 20px;
                    border-radius: 6px;
                    cursor: pointer;
                    font-size: 16px;
                }
                .config-info {
                    background: #e8f4fd;
                    padding: 10px;
                    border-radius: 6px;
                    margin-bottom: 15px;
                    font-size: 14px;
                    color: #333;
                }
            </style>
        </head>
        <body>
            <div class="chatbot-container">
                <div class="header">
                    <h2>🤖 Chatbot</h2>
                    <button class="close-btn" onclick="closeChatbot()">Close</button>
                </div>
                
                <div class="config-info">
                    <strong>Configuration:</strong><br>
                    API Key: <span id="apiKey">\(apiKey)</span><br>
                    User ID: <span id="userId">\(userId ?? "Not set")</span><br>
                    User Profile: <span id="userProfile"></span>
                </div>
                
                <div class="chat-area" id="chatArea">
                    <p><em>Chatbot initialized with API key: \(apiKey)</em></p>
                    <p><em>Ready to chat!</em></p>
                </div>
                
                <div class="input-area">
                    <input type="text" class="message-input" id="messageInput" placeholder="Type your message..." onkeypress="handleKeyPress(event)">
                    <button class="send-btn" onclick="sendMessage()">Send</button>
                </div>
            </div>
            
            <script>
                function sendMessage() {
                    const input = document.getElementById('messageInput');
                    const message = input.value.trim();
                    
                    if (message) {
                        const chatArea = document.getElementById('chatArea');
                        chatArea.innerHTML += '<p><strong>You:</strong> ' + message + '</p>';
                        
                        // Send message to iOS
                        window.webkit.messageHandlers.iOSListener.postMessage(JSON.stringify({
                            type: 'message',
                            content: message,
                            timestamp: Date.now()
                        }));
                        
                        input.value = '';
                        
                        // Simulate bot response
                        setTimeout(() => {
                            chatArea.innerHTML += '<p><strong>Bot:</strong> Thanks for your message: "' + message + '"</p>';
                            chatArea.scrollTop = chatArea.scrollHeight;
                        }, 1000);
                    }
                }
                
                function handleKeyPress(event) {
                    if (event.key === 'Enter') {
                        sendMessage();
                    }
                }
                
                function closeChatbot() {
                    window.webkit.messageHandlers.iOSListener.postMessage(JSON.stringify({
                        type: 'close',
                        timestamp: Date.now()
                    }));
                }
                
                // Auto-scroll chat area
                const chatArea = document.getElementById('chatArea');
                chatArea.scrollTop = chatArea.scrollHeight;
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iOSListener", let body = message.body as? String {
            // Try to parse as JSON first
            if let data = body.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                if let type = json["type"] as? String {
                    switch type {
                    case "close":
                        // Handle close request
                        dismiss(animated: true)
                    case "message":
                        // Handle message
                        if let content = json["content"] as? String {
                            onJSCallback?(content)
                        }
                    default:
                        onJSCallback?(body)
                    }
                } else {
                    onJSCallback?(body)
                }
            } else {
                // Fallback to simple string handling
                onJSCallback?(body)
            }
        }
    }
}

