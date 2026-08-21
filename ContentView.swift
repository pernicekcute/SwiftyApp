import SwiftUI

// MARK: - Tab Enum
enum AppTab: Hashable {
    case global
    case second
    case search
}

// MARK: - Main TabView Container
struct MainTabView: View {
    @State private var selectedTab: AppTab = .global
    @State private var previousTab: AppTab = .global
    @State private var showSearchSheet: Bool = false
    @State private var showBetaAlert: Bool = true

    var body: some View {
        TabView(selection: $selectedTab) {
            // First Page: Global
            Tab("Global", systemImage: "globe", value: AppTab.global) {
                NavigationStack {
                    GlobalView()
                }
            }

            // Second Page
            Tab("Developer Tests", systemImage: "hammer.fill", value: AppTab.second) {
                NavigationStack {
                    SecondTabView()
                }
            }

            // Search Tab
            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                Color.clear
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .search {
                showSearchSheet = true
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchSheetView()
        }
        .alert("App is in Beta", isPresented: $showBetaAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("This app is currently under development. Some features may change or be incomplete.")
        }
    }
}

// MARK: - 1st Page: Global
struct GlobalView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.title2)
                .bold()
        }
        .padding()
        .navigationTitle("Global")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheetView()
        }
    }
}

// MARK: - 2nd Page: Developer & Utility Tools
struct SecondTabView: View {
    @State private var showSettingsSheet = false
    @State private var enableVerboseLogs = true
    @State private var simulateOffline = false
    @State private var cacheSizeMB: Double = 24.5
    @State private var showClearCacheAlert = false

    var body: some View {
        Form {
            // Section 1: System & Build Info
            Section("Build Information") {
                LabeledContent("App Version", value: "1.0.0 (Beta)")
                LabeledContent("Build Number", value: "104")
                LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                LabeledContent("Environment", value: "Staging")
            }

            // Section 2: Debug Toggles
            Section("Debug Overrides") {
                Toggle(isOn: $enableVerboseLogs) {
                    Label("Verbose Console Logs", systemImage: "terminal")
                }
                
                Toggle(isOn: $simulateOffline) {
                    Label("Simulate Offline Mode", systemImage: "wifi.slash")
                }
            }

            // Section 3: Data & Storage
            Section("Cache & Storage") {
                LabeledContent("Cache Size", value: String(format: "%.1f MB", cacheSizeMB))

                Button(role: .destructive) {
                    showClearCacheAlert = true
                } label: {
                    Label("Clear Local Cache", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Dev Tools")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheetView()
        }
        .confirmationDialog("Clear Cache?", isPresented: $showClearCacheAlert, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                cacheSizeMB = 0.0
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will purge all temporary cached network responses.")
        }
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Settings",
                    systemImage: "gearshape",
                    description: Text("Settings is not done and currently is in this state.")
                )
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.footnote.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .clipShape(Circle())
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Custom Search Sheet View
struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Search",
                    systemImage: "magnifyingglass",
                    description: Text("Type a query to search across the app.")
                )
            }
            .searchable(text: $searchText, prompt: "Search...")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.footnote.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .clipShape(Circle())
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    MainTabView()
}
