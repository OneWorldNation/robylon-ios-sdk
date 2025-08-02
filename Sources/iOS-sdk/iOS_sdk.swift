// The Swift Programming Language
// https://docs.swift.org/swift-book
import UIKit

public struct iOS_sdk {
    @MainActor public static func createButton(action: @escaping (String) -> Void) -> UIButton {
        return CustomButton(callback: action)
    }
}
