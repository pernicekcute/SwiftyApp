import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Fullscreen red background ignoring safe area boundaries
            Color.red
                .ignoresSafeArea()
            
            // Image with white color rendering, transparent blacks, and 50% opacity
            Image("A-90JUMPSCARE")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.white)
                .colorMultiply(.white)
                .opacity(0.5)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
