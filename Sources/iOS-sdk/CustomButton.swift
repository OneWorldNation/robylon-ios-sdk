//
//  CustomButton.swift
//  iOS-sdk
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import UIKit

final class CustomButton: UIButton {
    
    private var callback: ((String) -> Void)?

    init(callback: @escaping (String) -> Void) {
        super.init(frame: .zero)
        self.callback = callback
        setupButton()
        fetchAttributesAndApply()
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        self.setTitle("Loading...", for: .normal)
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = 8
    }

    private func fetchAttributesAndApply() {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setTitle("Open WebView", for: .normal)
            self.backgroundColor = .systemBlue
            self.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func buttonTapped() {
        // Use the Chatbot singleton to open the chatbot
        Chatbot.shared.openChatbot()
    }
}
