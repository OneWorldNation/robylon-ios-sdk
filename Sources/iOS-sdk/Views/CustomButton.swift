//
//  CustomButton.swift
//  iOS-sdk
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import UIKit

@MainActor
public class CustomButton: UIButton {
    
    // MARK: - Properties
    private var callback: ((String) -> Void)?
    private var config: CustomButtonConfig?
    
    // MARK: - Initializers
    public convenience init(callback: @escaping (String) -> Void) {
        self.init(type: .system)
        self.callback = callback
        setupDefaultButton()
    }
    
    public convenience init(config: CustomButtonConfig, callback: @escaping (String) -> Void) {
        self.init(type: .system)
        self.config = config
        self.callback = callback
        setupButtonWithConfig()
    }
    
    // MARK: - Setup Methods
    private func setupDefaultButton() {
        setTitle("Chat", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Set default size
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    private func setupButtonWithConfig() {
        guard let config = config else {
            setupDefaultButton()
            return
        }
        
        // Set title
        if let title = config.title, !title.isEmpty {
            setTitle(title, for: .normal)
        } else {
            setTitle("Help & Support", for: .normal)
        }
        
        // Set title color (white for dark backgrounds, black for light backgrounds)
        setTitleColor(.white, for: .normal)
        
        // Set background color
        if let backgroundColorString = config.backgroundColor, !backgroundColorString.isEmpty {
            backgroundColor = UIColor(hex: backgroundColorString) ?? .systemBlue
        } else {
            backgroundColor = .systemBlue
        }
        
        // Set corner radius and shadow
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4
        
        // Load image if available
        if let imageURLString = config.imageURL, !imageURLString.isEmpty {
            loadImage(from: imageURLString)
        }
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Set size based on content
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Adjust width based on content
        if let title = config.title, !title.isEmpty {
            let titleWidth = title.size(withAttributes: [.font: titleLabel?.font ?? UIFont.systemFont(ofSize: 16)]).width
            let minWidth = max(titleWidth + 40, 120) // Add padding
            widthAnchor.constraint(equalToConstant: minWidth).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: 120).isActive = true
        }
    }
    
    // MARK: - Private Methods
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.setImage(image, for: .normal)
                    self?.imageView?.contentMode = .scaleAspectFit
                    self?.imageView?.layer.cornerRadius = 20
                    self?.imageView?.clipsToBounds = true
                    
                    // Adjust image size
                    self?.imageView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    self?.imageView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
                }
            }
        }.resume()
    }
    
    @objc private func buttonTapped() {
        callback?("Button tapped")
    }
}

// MARK: - UIColor Extension for Hex Colors
extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
