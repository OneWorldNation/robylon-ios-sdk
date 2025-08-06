//
//  ContentView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI
import iOS_sdk

struct ContentView: View {
    @StateObject private var chatbotViewModel = iOS_sdk.createChatbotViewModel()
    @StateObject private var configViewModel = iOS_sdk.createChatbotConfigurationViewModel()
    @State private var showingConfiguration = false
    
    // Static configuration for demonstration
    private static let demoConfig = ChatbotConfiguration(
        apiKey: "30e4fab6-cadb-4b99-b1e7-30fca6e147ac",
        orgId: nil,
        userId: "",
        userToken: "asdsadassa",
        userProfile: nil,
        eventHandler: { event in
            print("[SDK Event] Type: \(event.type.rawValue), Timestamp: \(event.timestamp), Data: \(String(describing: event.data))")
        }
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🤖 Chatbot SDK Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Status Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Status:")
                        .font(.headline)
                    
                    HStack {
                        Circle()
                            .fill(chatbotViewModel.isInitialized ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(chatbotViewModel.isInitialized ? "Initialized" : "Not Initialized")
                            .foregroundColor(chatbotViewModel.isInitialized ? .green : .red)
                    }
                    
                    HStack {
                        Circle()
                            .fill(chatbotViewModel.isChatbotOpen ? Color.blue : Color.gray)
                            .frame(width: 12, height: 12)
                        Text(chatbotViewModel.isChatbotOpen ? "Chatbot Open" : "Chatbot Closed")
                            .foregroundColor(chatbotViewModel.isChatbotOpen ? .blue : .gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Configuration Summary
                if configViewModel.isConfigurationValid {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Configuration:")
                            .font(.headline)
                        Text(configViewModel.configurationSummary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Buttons
                VStack(spacing: 15) {
                    Button("⚙️ Configure Chatbot") {
                        showingConfiguration = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if chatbotViewModel.isInitialized {
                        ChatbotButtonView()
                            .frame(width: 240, height: 50)
                        
                        Button("🔄 Refresh Session") {
                            chatbotViewModel.refreshSession()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("🔄 Reset Chatbot") {
                            chatbotViewModel.reset()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    } else {
                        Button("🚀 Initialize Chatbot") {
                            initializeChatbot()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!configViewModel.isConfigurationValid)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Chatbot SDK")
            .sheet(isPresented: $showingConfiguration) {
                ConfigurationView(configViewModel: configViewModel)
            }
            .alert("Error", isPresented: .constant(chatbotViewModel.errorMessage != nil)) {
                Button("OK") {
                    chatbotViewModel.errorMessage = nil
                }
            } message: {
                Text(chatbotViewModel.errorMessage ?? "")
            }
            .onAppear {
                let config = ChatbotConfiguration(
                    apiKey: "30e4fab6-cadb-4b99-b1e7-30fca6e147ac",
                    orgId: nil,
                    userId: "",
                    userToken: "asdsadassa",
                    userProfile: nil,
                    eventHandler: { event in
                        print("[SDK Event] Type: \(event.type.rawValue), Timestamp: \(event.timestamp), Data: \(String(describing: event.data))")
                    }
                )
                iOS_sdk.initializeChatbot(config: config)
            }
        }
    }
    
    private func initializeChatbot() {
        chatbotViewModel.initializeChatbot(
            apiKey: configViewModel.apiKey,
            orgId: configViewModel.orgId.isEmpty ? nil : configViewModel.orgId,
            userId: configViewModel.userId.isEmpty ? nil : configViewModel.userId,
            userToken: configViewModel.userToken.isEmpty ? nil : configViewModel.userToken,
            userProfile: configViewModel.userProfile
        )
    }
}

#Preview {
    ContentView()
}
