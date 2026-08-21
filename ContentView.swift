import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }

            Tab(role: .settings) {
                SettingsView()
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
    // AppStorage automatically persists these keys to UserDefaults
    @AppStorage("isLiquidGlassEnabled") private var isLiquidGlassEnabled: Bool = true
    @AppStorage("UIDesignRequiresCompatibility") private var requiresCompatibility: Bool = false

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: Binding(
                    get: { isLiquidGlassEnabled },
                    set: { newValue in
                        isLiquidGlassEnabled = newValue
                        // Setting UIDesignRequiresCompatibility to true disables modern glass materials
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
    MainTabView()
}
