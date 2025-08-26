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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🤖 Chatbot SDK Demo to integrate with Swiftui")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Chatbot SDK")
            .background(
                ParentViewProvider { parentView in
                    // This closure will be called with the actual UIView
                    initializeChatbot(with: parentView)
                }
            )
        }
    }
    
    private func initializeChatbot(with parentView: UIView) {
        let config = ChatbotConfiguration(
            apiKey: "30e4fab6-cadb-4b99-b1e7-30fca6e147ac", // "82d83024-c677-4e93-bb95-997b38bc4209",
            orgId: nil,
            userId: UUID().uuidString, // Generate a proper userId
            userToken: "asdsadassa",
            userProfile: UserProfile(
                name: "Test User",
                email: "test@example.com"
            ),
            eventHandler: { event in
                print("📲 [SDK Event] Type: \(event.type.rawValue), Timestamp: \(event.timestamp), Data: \(String(describing: event.data))")
            },
            parentView: parentView,
            debugMode: true,
            presetationStyle: .fullscreen
        )
        
        RobylonSDK.initializeChatbot(config: config)
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

// MARK: - Custom Button View
struct CustomButtonView: UIViewRepresentable {
    let button: UIButton
    
    func makeUIView(context: Context) -> UIButton {
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        // Update if needed
    }
}

#Preview {
    ContentView()
}
