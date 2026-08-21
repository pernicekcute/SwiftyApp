//
//  ContentView.swift
//  ExampleApp
//
//  Created by User on 2026/08/21.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // A rich background is required for Liquid Glass to bend light properly
            LinearGradient(
                colors: [.orange, .purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.white)
                
                Text("Hello, world!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                // Real iOS 26 Native Liquid Glass Button
                Button(action: {
                    withAnimation {
                        isLoading.toggle()
                    }
                }) {
                    HStack(spacing: 10) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "drop.fill")
                            Text("Liquid Glass")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                }
                // NATIVE API: Use the iOS 26 glass prominent button style
                .buttonStyle(.glassProminent)
                .tint(.orange)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
