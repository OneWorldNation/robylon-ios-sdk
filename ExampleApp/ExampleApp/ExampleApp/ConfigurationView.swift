import SwiftUI
import iOS_sdk

struct ConfigurationView: View {
    @ObservedObject var configViewModel: ChatbotConfigurationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Configuration") {
                    TextField("API Key", text: $configViewModel.apiKey)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Organization ID (Optional)", text: $configViewModel.orgId)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("User Configuration") {
                    TextField("User ID (Optional)", text: $configViewModel.userId)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("User Token (Optional)", text: $configViewModel.userToken)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("User Profile") {
                    TextField("Name (Optional)", text: $configViewModel.userName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Email (Optional)", text: $configViewModel.userEmail)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Actions") {
                    Button("Load Default Configuration") {
                        configViewModel.loadDefaultConfiguration()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset Configuration") {
                        configViewModel.resetConfiguration()
                    }
                    .foregroundColor(.red)
                }
                
                Section("Configuration Summary") {
                    if configViewModel.isConfigurationValid {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("✅ Configuration is valid")
                                .foregroundColor(.green)
                            Text(configViewModel.configurationSummary)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("❌ API Key is required")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Chatbot Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}



#Preview {
    ConfigurationView(configViewModel: ChatbotConfigurationViewModel())
} 