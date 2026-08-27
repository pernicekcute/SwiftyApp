import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack(spacing: 20) {
                Text("Welcome!")
                    .font(.title2)
                    .bold()
                
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world!")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            TabBarView()
                .tabItem {
                    Label("TabBar", systemImage: "list.dash")
                }
                .tag(1)
        }
    }
}

struct TabBarView: View {
    @State private var innerSelection = 0

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Options", selection: $innerSelection) {
                    Text("Overview").tag(0)
                    Text("Settings").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                Spacer()

                if innerSelection == 0 {
                    Text("Here's the Overview page!")
                        .font(.headline)
                } else {
                        Text("Here's the Settings page!")
                        .font(.headline)
                }

                Spacer()
            }
            .navigationTitle("TabBar page")
        }
    }
}

#Preview {
    ContentView()
}
