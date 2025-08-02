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
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadSampleHTML()
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

    private func loadSampleHTML() {
        let html = """
        <html>
        <body>
        <h1>Hello from WebView</h1>
        <button onclick="sendMessage()">Send to iOS</button>
        <script>
            function sendMessage() {
                window.webkit.messageHandlers.iOSListener.postMessage("Hello from JS!");
            }
        </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iOSListener", let body = message.body as? String {
            onJSCallback?(body)
            dismiss(animated: true)
        }
    }
}

