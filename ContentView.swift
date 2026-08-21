import SwiftUI

struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Button(action: { isLoading.toggle() }) {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "drop.fill").foregroundStyle(.cyan)
                        Text("Liquid Glass").fontWeight(.semibold).foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 28)
                // The REAL native glass API
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}
