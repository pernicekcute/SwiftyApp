import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 20) {
            Picker("Select Tab", selection: $selectedTab) {
                Text("Globe").tag(0)
                Text("Text").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TabView(selection: $selectedTab) {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                }
                .tag(0)
                
                VStack {
                    Text("Hello, world!")
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .none))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
