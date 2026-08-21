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

// MARK: - 2nd Page: Second View
struct SecondTabView: View {
    @State private var showSettingsSheet = false
    @State private var testCounter = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Developer Tests")
                .font(.title3.bold())

            Text("Executions: \(testCounter)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Fully populated button with explicit text, icon, and working action
            Button {
                testCounter += 1
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Run Test Action")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding()
        .navigationTitle("Developer Tests")
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
