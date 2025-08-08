//
//  CustomButton.swift
//  iOS-sdk
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import UIKit

@MainActor
final class CustomButton: UIButton {
    
    // MARK: - Properties
    private var callback: (() -> Void)?
    private var config: CustomButtonConfig?
    
    // MARK: - Initializers
    convenience init(callback: @escaping () -> Void) {
        self.init(type: .system)
        self.callback = callback
        setupDefaultButton()
    }
    
    convenience init(config: CustomButtonConfig, callback: @escaping () -> Void) {
        self.init(type: .system)
        self.config = config
        self.callback = callback
        setupButtonWithConfig()
    }
    
    // MARK: - Setup Methods
    private func setupDefaultButton() {
        setTitle("Chat", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemYellow
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
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50) // Default frame
        
        // Set title color (white for dark backgrounds, black for light backgrounds)
//        setTitleColor(.black, for: .normal)
        
        // Set background color
//        if let backgroundColorString = config.backgroundColor, !backgroundColorString.isEmpty {
//            backgroundColor = UIColor(hex: backgroundColorString) ?? .systemBlue
//        } else {
//            backgroundColor = .systemBlue
//        }
        
        // Set corner radius and shadow
//        layer.cornerRadius = 25
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowOpacity = 0.3
//        layer.shadowRadius = 4
        
        // Configure button based on launch type
//        configureButtonForLaunchType(config.launchType, config: config)
        configureButtonForLaunchType("text", config: config)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Set size based on content
//        translatesAutoresizingMaskIntoConstraints = false
//        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Adjust width based on content and launch type
//        adjustWidthForLaunchType(config.launchType, config: config)
    }
    
    private func configureButtonForLaunchType(_ launchType: String?, config: CustomButtonConfig) {
        guard let launchType = launchType?.uppercased() else {
            // Default to TEXT if no launch type specified
            configureTextOnlyButton(config: config)
            return
        }
        
        switch launchType {
        case "TEXT":
            configureTextOnlyButton(config: config)
            
        case "IMAGE":
            configureImageOnlyButton(config: config)
            
        case "TEXTUAL_IMAGE":
            configureTextualImageButton(config: config)
            
        default:
            // Default to TEXT for unknown types
            configureTextOnlyButton(config: config)
        }
    }
    
    private func configureTextOnlyButton(config: CustomButtonConfig) {
        // Set title
        if let title = config.title, !title.isEmpty {
            setTitle(title, for: .normal)
        } else {
            setTitle("Help & Support", for: .normal)
        }
        
        // Remove any existing image
        setImage(nil, for: .normal)
        
        // Configure title label
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel?.textAlignment = .center
        
        // Set content insets for text-only button
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
    
    private func configureImageOnlyButton(config: CustomButtonConfig) {
        // Remove title
//        setTitle(nil, for: .normal)
        
        // For IMAGE type, make the button background transparent
        // The image itself will provide the visual appearance
//        backgroundColor = .clear
        
        // Remove shadow for image-only button to make it look more natural
//        layer.shadowColor = UIColor.clear.cgColor
//        layer.shadowOpacity = 0
        
        self.clipsToBounds = true
        
        // Load and configure image
        if let imageURLString = config.imageURL, !imageURLString.isEmpty {
            loadCircularImage(from: imageURLString)
        } else {
            // Set a default image if no URL provided
//            setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
//            configureCircularImageView()
        }
        
        // Set content insets for image-only button
//        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func configureTextualImageButton(config: CustomButtonConfig) {
        // Set title
        if let title = config.title, !title.isEmpty {
            setTitle(title, for: .normal)
        } else {
            setTitle("Help & Support", for: .normal)
        }
        
        // Configure title label
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel?.textAlignment = .left
        
        // Load and configure image
        if let imageURLString = config.imageURL, !imageURLString.isEmpty {
            loadCircularImage(from: imageURLString)
        } else {
            // Set a default image if no URL provided
            setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            configureCircularImageView()
        }
        
        // Set content insets for textual-image button
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8)
        
        // Configure image position (image on the right)
        semanticContentAttribute = .forceRightToLeft
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    private func adjustWidthForLaunchType(_ launchType: String?, config: CustomButtonConfig) {
        guard let launchType = launchType?.uppercased() else {
            // Default width for unknown types
            widthAnchor.constraint(equalToConstant: 120).isActive = true
            return
        }
        
        switch launchType {
        case "TEXT":
            // Width based on text content
            if let title = config.title, !title.isEmpty {
                let titleWidth = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]).width
                let minWidth = max(titleWidth + 40, 120) // Add padding
                widthAnchor.constraint(equalToConstant: minWidth).isActive = true
            } else {
                widthAnchor.constraint(equalToConstant: 120).isActive = true
            }
            
        case "IMAGE":
            // Fixed width for circular image button
            widthAnchor.constraint(equalToConstant: 25).isActive = true
            
        case "TEXTUAL_IMAGE":
            // Width based on text content plus image space
            if let title = config.title, !title.isEmpty {
                let titleWidth = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]).width
                let minWidth = max(titleWidth + 80, 140) // Add padding for text + image
                widthAnchor.constraint(equalToConstant: minWidth).isActive = true
            } else {
                widthAnchor.constraint(equalToConstant: 140).isActive = true
            }
            
        default:
            widthAnchor.constraint(equalToConstant: 120).isActive = true
        }
    }
    
    private func loadCircularImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.setImage(image, for: .normal)
                    self?.configureCircularImageView()
                }
            }
        }.resume()
    }
    
    private func configureCircularImageView() {
        // Make the button itself circular
        layer.cornerRadius = 25 // Half of 50px height for circular button
        
        // Configure the image view
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.cornerRadius = 25 // Make image view circular to match button
        imageView?.clipsToBounds = true
        
        // Remove border for cleaner look
        imageView?.layer.borderWidth = 0
        
        // Set image size to fill the entire button
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        
        // For IMAGE type, make image fill the entire button
        if config?.launchType?.uppercased() == "IMAGE" {
            imageView?.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            imageView?.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            imageView?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            imageView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        } else {
            // For TEXTUAL_IMAGE type, keep smaller circular image
            imageView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView?.layer.borderWidth = 2
            imageView?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    // MARK: - Private Methods
    @objc private func buttonTapped() {
        callback?()
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
