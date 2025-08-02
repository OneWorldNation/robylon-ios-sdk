//
//  SDKButtonView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI
import iOS_sdk

struct SDKButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIButton {
        let button = iOS_sdk.createButton { message in
            print("JS Callback: \(message)")
        }
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        // no-op
    }
}
struct SDKButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SDKButtonView()
            .frame(width: 200, height: 50)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}
