//
//  ContentView.swift
//  ExampleApp
//
//  Created by Aadesh Maheshwari on 02/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Demo App for iOSSDK")
                .font(.title)
                .padding()

            SDKButtonView()
                .frame(width: 240, height: 60)
        }
    }
}

#Preview {
    ContentView()
}
