//
//  ContentView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI
import iOS_sdk

struct ContentView: View {
    @State private var customButton: UIButton?
    
    // Static configuration for demonstration
    private static let demoConfig = ChatbotConfiguration(
        apiKey: "30e4fab6-cadb-4b99-b1e7-30fca6e147ac",
        orgId: nil,
        userId: "",
        userToken: "asdsadassa",
        userProfile: nil,
        eventHandler: { event in
            print("[SDK Event] Type: \(event.type.rawValue), Timestamp: \(event.timestamp), Data: \(String(describing: event.data))")
        },
        parentFrame: UIScreen.main.bounds
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🤖 Chatbot SDK Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Chatbot SDK")
            .onAppear {
                iOS_sdk.initializeChatbot(config: Self.demoConfig)
                
                // Create custom button after initialization
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let customConfig = Chatbot.shared.getCustomBottomConfig() {
                        self.customButton = iOS_sdk.createCustomButton(config: customConfig) { message in
                            print("Custom button tapped: \(message)")
                            iOS_sdk.openChatbot()
                        }
                    }
                }
            }
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
