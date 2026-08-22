import SwiftUI

// MARK: - Tab Enum
enum AppTab: Hashable {
    case global
    case second
    case third
    case search
}

// MARK: - Main TabView Container (iOS 18+)
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

            // Second Page: Local
            Tab("Local", systemImage: "iphone", value: AppTab.second) {
                NavigationStack {
                    SecondTabView()
                }
            }

            // Third Page: Exploits
            Tab("Exploits", systemImage: "cpu.fill", value: AppTab.third) {
                NavigationStack {
                    ExploitsTabView()
                }
            }

            Tab("Other", systemImage: "book", value: AppTab.third) {
                NavigationStack {
                    OtherTabView()
                }
            }

            // Search Tab with Search Role
            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                Color.clear
            }
        }
        .tint(.orange)
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

// MARK: - 1st Page: Global
struct OtherTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "book")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Nothing here yet!")
                .font(.title2)
                .bold()
        }
        .padding()
        .navigationTitle("Other")
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

// MARK: - Exploits Tab
struct ExploitsTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.tint)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Partial Restore Exploits")
                            .font(.title2)
                            .bold()
                        Text("MobileBackup2 system write vectors")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Label("SparseRestore", systemImage: "bolt.shield.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    
                    Text("Manipulates iOS's local restore daemon using sparse backup data to write custom configuration files into system paths without a full device wipe.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• **Vector:** Partial backup file injection")
                        Text("• **Support:** iOS 16.0 – iOS 18.1 Beta 4")
                        Text("• **Edits:** MobileGestalt & preference tweaks")
                        Text("• **Status:** Patched (iOS 18.1 Beta 5+)")
                    }
                    .font(.footnote)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("BookRestore", systemImage: "book.pages.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Text("An evolved exploit targeting specific app domain paths to bypass updated file-write protections on newer iOS firmware versions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• **Vector:** App domain preference restore")
                        Text("• **Support:** iOS 18.2 – iOS 26.x")
                        Text("• **Edits:** Selective UI & system behavior tweaks")
                        Text("• **Status:** Active (Preference writes)")
                    }
                    .font(.footnote)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label("Developer Note & Risk", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.red)
                    
                    Text("Invalid plist modifications can trigger recovery bootloops requiring an iTunes/Finder restore. System updates or device wipes clear all applied tweaks.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Info about Exploits")
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

// MARK: - 2nd Page: Local
struct SecondTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, user!")
                .font(.title2)
                .bold()
        }
        .padding()
        .navigationTitle("Local")
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
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var buttonTitle: String = ""
    @State private var isShowingAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                ContentUnavailableView(
                    "Settings",
                    systemImage: "gearshape",
                    description: Text("Settings is not done and currently is in this state.")
                )
                .listRowBackground(Color.clear)

                Section("Dialog Inputs") {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message)
                    TextField("Button Label", text: $buttonTitle)
                }

                Section {
                    Button("Show Dialog") {
                        isShowingAlert = true
                    }
                }
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
            .alert(title.isEmpty ? "Alert" : title, isPresented: $isShowingAlert) {
                Button(buttonTitle.isEmpty ? "OK" : buttonTitle) { }
            } message: {
                if !message.isEmpty {
                    Text(message)
                }
            }
        }
        .presentationDetents([.medium])
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
        .presentationDetents([.medium])
    }
}

#Preview {
    MainTabView()
}
