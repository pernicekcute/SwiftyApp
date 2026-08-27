import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .tabItem {
                    Text("Globe")
                }
            
            Text("Hello, world!")
                .tabItem {
                    Text("Test")
                }
        
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
