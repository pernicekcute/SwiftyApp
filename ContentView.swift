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
            // Background gradient to demonstrate the liquid glass blur
            LinearGradient(
                colors: [.orange, .yellow, .orange],
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

                // Native "Liquid Glass" Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLoading.toggle()
                    }
                }) {
                    HStack(spacing: 10) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.cyan)
                            Text("Liquid Glass")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 28)
                    // Native ultra-thin glass material backdrop
                    .background(.ultraThinMaterial, in: Capsule())
                    // Subtle glass edge outline and inner glare
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
