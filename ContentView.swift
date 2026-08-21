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

    var body: some View {
        TabView(selection: $selectedTab) {
            // First Page: Called "Global" with Default Xcode Template
            Tab("Global", systemImage: "globe", value: AppTab.global) {
                NavigationStack {
                    GlobalView()
                }
            }

            // Second Page
            Tab("Second", systemImage: "square.stack.3d.up", value: AppTab.second) {
                NavigationStack {
                    SecondTabView()
                }
            }

            // Search Tab using role: .search
            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                // Empty view container since selecting search triggers the sheet
                Color.clear
            }
        }
        // Intercept tab selection when Search is tapped
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .search {
                showSearchSheet = true
                // Revert to previous tab so the current view remains active behind the sheet
                selectedTab = previousTab
            } else {
                // Keep track of active non-search tab
                previousTab = newValue
            }
        }
        // Present custom Search sheet
        .sheet(isPresented: $showSearchSheet) {
            SearchSheetView()
        }
    }
}

// MARK: - 1st Page: Global (Default Xcode Template View)
struct GlobalView: View {
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
    }
}

// MARK: - 2nd Page: Placeholder View
struct SecondTabView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Second Page Content")
                .font(.title3)
        }
        .padding()
        .navigationTitle("Second")
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    MainTabView()
}
