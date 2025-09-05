//
//  ContentView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI
import RobylonSDK

struct ContentView: View {
    @State private var customButton: UIButton?
    
    // Reusable config generator
    private func makeConfig(parentView: UIView? = nil) -> ChatbotConfiguration {
        ChatbotConfiguration(
            apiKey: "30e4fab6-cadb-4b99-b1e7-30fca6e147ac",
            orgId: nil,
            userId: UUID().uuidString,
            userToken: "asdsadassa",
            userProfile: ChatbotUserProfile(
                name: "Test User",
                email: "test@example.com"
            ),
            eventHandler: { event in
                print("📲 [SDK Event] Type: \(event.type.rawValue), Timestamp: \(event.timestamp), Data: \(String(describing: event.data))")
            },
            parentView: parentView,
            debugMode: true,
            presentationStyle: .fullscreen
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🤖 Chatbot SDK Demo to integrate with Swiftui")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Button("Open Chatbot") {
                    let config = makeConfig(parentView: nil)
                    RobylonSDK.openChatbot(config: config)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Chatbot SDK")
            .background(
                ParentViewProvider { view in
                    let config = makeConfig(parentView: view)
//                    RobylonSDK.initializeChatbot(config: config)
                }
            )
        }
    }
}

// MARK: - Parent View Provider
struct ParentViewProvider: UIViewRepresentable {
    let onViewReady: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Call the closure when the view is ready
        DispatchQueue.main.async {
            onViewReady(uiView)
        }
    }
}

#Preview {
    ContentView()
}
