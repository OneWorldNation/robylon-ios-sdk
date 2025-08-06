//
//  SDKButtonView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI
import iOS_sdk

struct ChatbotButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIButton {
        let button = iOS_sdk.createStyledButton(
            title: "💬 Open Chatbot",
            backgroundColor: ChatbotConstants.Colors.primaryBlue,
            textColor: .white,
            cornerRadius: ChatbotConstants.defaultCornerRadius,
            fontSize: 18,
            fontWeight: .semibold
        )
        
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        // no-op
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    class Coordinator: NSObject {
        @objc func buttonTapped() {
            iOS_sdk.openChatbot()
        }
    }
}
struct ChatbotButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotButtonView()
            .frame(width: 200, height: 50)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}
