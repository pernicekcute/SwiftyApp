import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

// MARK: - Individual Page Structs
struct HomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "house.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            Text("Welcome to the Home Screen")
                .font(.title2)
                .bold()
        }
    }
}

struct SettingsView: View {
    @AppStorage("isLiquidGlassEnabled") private var isLiquidGlassEnabled: Bool = true
    @AppStorage("UIDesignRequiresCompatibility") private var requiresCompatibility: Bool = false

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: Binding(
                    get: { isLiquidGlassEnabled },
                    set: { newValue in
                        isLiquidGlassEnabled = newValue
                        requiresCompatibility = !newValue
                    }
                )) {
                    Label("Liquid Glass Effects", systemImage: "drop.fill")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
