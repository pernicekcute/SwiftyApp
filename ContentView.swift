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
            // First Page: Global
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
    }
}

// MARK: - 1st Page: Global
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
        .toolbar {
            // Top-right button in the app
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action for top-right app button
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

// MARK: - 2nd Page: Second View
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
        .toolbar {
            // Top-right button in the app
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action for top-right app button
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
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
                // Top-right blue button with a checkmark on the sheet
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.footnote.bold())
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
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
