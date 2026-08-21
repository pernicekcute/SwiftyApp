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
    // Read the shared state from UserDefaults
    @AppStorage("isLiquidGlassEnabled") private var isLiquidGlassEnabled: Bool = true

    var body: some View {
        ZStack {
            // Background gradient so the glass effect is noticeable when enabled
            LinearGradient(
                colors: [.orange, .purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "house.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Text("Welcome to the Home Screen")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
            }
            .padding(30)
            // Dynamically apply glass material or standard solid background based on setting
            .background(
                Group {
                    if isLiquidGlassEnabled {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.black.opacity(0.7))
                    }
                }
            )
            .animation(.smooth, value: isLiquidGlassEnabled)
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
