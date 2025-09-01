//
//  CustomButton.swift
//  RobylonSDK
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import UIKit

@MainActor
final class CustomButton: UIButton {
    
    // MARK: - Properties
    private var callback: (() -> Void)?
    private var config: CustomButtonConfig?
    private let rightImageView = UIImageView()
    
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
        
        // Set corner radius and shadow
        layer.cornerRadius = 25
        applyShadow()
        
        // Configure button based on launch type
        configureButtonForLaunchType(config.launchType, config: config)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Set size based on content
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyShadow() {
        // Add shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4
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
        
        // Set background color to brownish-grey (matching screenshot 1)
        if let backgroundColorString = config.backgroundColor, !backgroundColorString.isEmpty {
            backgroundColor = UIColor(hex: backgroundColorString) ?? UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Brownish-grey
        }
        // Set text color to white
        setTitleColor(ChatbotUtils.getBestFontColor(for: backgroundColor!), for: .normal)
        
        // Set content insets for text-only button
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        // Apply corner radius and shadow after constraints are set
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Set corner radius to half of the button height for perfect pill shape
            let buttonHeight = self.frame.height > 0 ? self.frame.height : 50
            self.layer.cornerRadius = buttonHeight / 2
            self.applyShadow()
        }
    }
    
    private func configureImageOnlyButton(config: CustomButtonConfig) {
        // For IMAGE type, make the button background transparent
        // The image itself will provide the visual appearance
        backgroundColor = .clear
        
        // Set frame size to 25x25 for IMAGE type
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        tintColor = .clear
        
        // Load and configure image
        if let imageURLString = config.imageURL, !imageURLString.isEmpty {
            loadCircularImage(from: imageURLString) { [weak self] image in
                self?.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                // Ensure image view is circular
                self?.imageView?.contentMode = .scaleAspectFill
                self?.imageView?.clipsToBounds = true
                self?.imageView?.layer.cornerRadius = 25
            }
        } else {
            // Set a default image if no URL provided
            setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        }
        
        // Set content insets for image-only button
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        
        // Set background color to brownish-grey (matching screenshot)
        if let backgroundColorString = config.backgroundColor, !backgroundColorString.isEmpty {
            backgroundColor = UIColor(hex: backgroundColorString) ?? UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        } else {
            backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Brownish-grey
        }
        
        // Set text color to white
        setTitleColor(ChatbotUtils.getBestFontColor(for: backgroundColor!), for: .normal)
        layer.cornerRadius = 25
        clipsToBounds = false
        applyShadow()
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        // Give room for text + image
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 60)
        // Image view setup
        rightImageView.layer.cornerRadius = 25
        rightImageView.layer.masksToBounds = true
        rightImageView.layer.borderWidth = 2
        rightImageView.layer.borderColor = UIColor.white.cgColor
        rightImageView.contentMode = .scaleAspectFill
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightImageView)
        
        NSLayoutConstraint.activate([
            rightImageView.widthAnchor.constraint(equalToConstant: 50),
            rightImageView.heightAnchor.constraint(equalToConstant: 50),
            rightImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            rightImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Load and configure image
        if let imageURLString = config.imageURL, !imageURLString.isEmpty {
            loadCircularImage(from: imageURLString) { [weak self] image in
                guard let self = self else { return }
                self.rightImageView.image = image.withRenderingMode(.alwaysOriginal)
            }
        } else {
            // Set a default image if no URL provided
            setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            imageView?.layer.cornerRadius = 25
            imageView?.layer.borderWidth = 2
            imageView?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    private func loadCircularImage(from urlString: String, completion: ((UIImage) -> Void)? = nil) {
        guard let url = URL(string: urlString) else { 
            // If URL is invalid, load placeholder image
            loadPlaceholderImage(completion: completion)
            return 
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                // If there's an error loading the image, load placeholder image
                DispatchQueue.main.async {
                    self.loadPlaceholderImage(completion: completion)
                }
                return
            }
            DispatchQueue.main.async {
                completion?(image)
            }
        }.resume()
    }
    
    private func loadPlaceholderImage(completion: ((UIImage) -> Void)? = nil) {
        guard let placeholderURL = URL(string: "https://chatbot.robylon.ai/chatbubble.png") else {
            // If placeholder URL is invalid, use system image
            let systemImage = UIImage(systemName: "person.circle.fill") ?? UIImage()
            completion?(systemImage)
            return
        }
        
        URLSession.shared.dataTask(with: placeholderURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data, error == nil,
                  let placeholderImage = UIImage(data: data) else {
                // If placeholder fails to load, use system image
                DispatchQueue.main.async {
                    let systemImage = UIImage(systemName: "person.circle.fill") ?? UIImage()
                    completion?(systemImage)
                }
                return
            }
            DispatchQueue.main.async {
                completion?(placeholderImage)
            }
        }.resume()
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
