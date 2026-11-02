import SwiftUI

struct ContentView: View {
    @State private var isRespringing = false
    @State private var showConfirmation = false // Controls the dialog state
    
    var body: some View {
        ZStyleView()
    }
    
    @ViewBuilder
    func ZStyleView() -> some View {
        VStack(spacing: 25) {
            // Visual Anchor Icon
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(isRespringing ? .red : .blue)
                .rotationEffect(.degrees(isRespringing ? 360 : 0))
                .animation(isRespringing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRespringing)
            
            VStack(spacing: 8) {
                Text("System Respring")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Forces a SpringBoard reload by rapidly exhausting available RAM.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            // The Trigger Button
            Button(action: {
                // Open the confirmation dialog instead of firing immediately
                showConfirmation = true
            }) {
                Text(isRespringing ? "Respringing..." : "Trigger Respring")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRespringing ? Color.red : Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .disabled(isRespringing)
            .padding(.horizontal, 40)
        }
        .padding()
        // Confirmation Dialog Configuration
        .alert("Confirm Respring", isPresented: &showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                isRespringing = true
                
                // Brief pause so the UI registers the tap before the memory freeze
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    executeMemoryPanic()
                }
            }
        } message: {
            Text("This will instantly crash the SpringBoard UI and lock your device. Ensure you don't have unsaved data open in other apps.")
        }
    }
    
    // Core Logic: Rapidly requests 100MB chunks of memory in an infinite loop
    private func executeMemoryPanic() {
        while true {
            let chunkSize = 1024 * 1024 * 100 // 100 Megabytes
            if let pointer = malloc(chunkSize) {
                memset(pointer, 1, chunkSize)
            }
        }
    }
}

#Preview {
    ContentView()
}
