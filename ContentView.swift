import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Label("Globe", systemImage: "globe") // Bonus: přidána ikona do tabu! 🌍
                    }
                
                Text("Hello, world!")
                    .tabItem {
                        Label("Test", systemImage: "star.fill") // Bonus: přidána ikona do tabu! ⭐
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
