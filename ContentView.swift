import SwiftUI
import Foundation

// MARK: - Tab Enum
enum AppTab: Hashable {
    case global
    case second
    case third
    case fourth
    case search
}

// MARK: - Main TabView Container (iOS 18+)
// MARK: - Main TabView Container (iOS 18+)
struct MainTabView: View {
    @State private var selectedTab: AppTab = .global
    @State private var showSearchSheet: Bool = false
    @State private var showBetaAlert: Bool = true

    var body: some View {
        TabView(selection: $selectedTab) {
            // First Page: Global (Rotating Globe)
            Tab(value: AppTab.global) {
                NavigationStack {
                    GlobalView()
                }
            } label: {
                Label("Global", systemImage: "globe")
                    .symbolEffect(.rotate, value: selectedTab == .global)
            }

            // Second Page: Local (Wiggling / Vibrating iPhone)
            Tab(value: AppTab.second) {
                NavigationStack {
                    SecondTabView()
                }
            } label: {
                Label("Local", systemImage: "iphone")
                    .symbolEffect(.wiggle, value: selectedTab == .second)
            }

            // Third Page: Exploits (Bouncing CPU)
            Tab(value: AppTab.third) {
                NavigationStack {
                    ExploitsTabView()
                }
            } label: {
                Label("Exploits", systemImage: "cpu.fill")
                    .symbolEffect(.bounce, value: selectedTab == .third)
            }

            // Fourth Page: Other (Small Jumping Book)
            Tab(value: AppTab.fourth) {
                NavigationStack {
                    OtherTabView()
                }
            } label: {
                Label("Other", systemImage: "book")
                    .symbolEffect(.bounce.up, value: selectedTab == .fourth)
            }

            // Search Tab (No Animation)
            Tab(value: AppTab.search, role: .search) {
                Color.clear
            } label: {
                Label("App", systemImage: "moon.stars.fill")
            }
        }
        .tint(.orange)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .search {
                showSearchSheet = true
                selectedTab = oldValue // Reverts selection so active tab content remains unchanged
            }
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("App is in Release", isPresented: $showBetaAlert) {
            Button("OK", role: .cancel) { }
            Button("Exit", role: .destructive) {
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        } message: {
            Text("This app is currently released but some features may change or be incomplete.")
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
                    Image(systemName: "gear")
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
                    Image(systemName: "gear")
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
                    Image(systemName: "gear")
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
                    Image(systemName: "gear")
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
    
    // Automatically retrieve the device system version
    private var sysVer: String {
        UIDevice.current.systemVersion
    }

    private var sysBuildNum: String {
        var size = 0
        sysctlbyname("hw.buildversion", nil, &size, nil, 0)
        
        guard size > 0 else { return "N/A" }
        
        var buffer = [CChar](repeating: 0, count: size)
        let result = sysctlbyname("hw.buildversion", &buffer, &size, nil, 0)
        
        guard result == 0 else { return "N/A" }
        return String(cString: buffer)
    }
    var body: some View {
        NavigationStack {
            Form {
                ContentUnavailableView(
                    "Settings",
                    systemImage: "gear",
                    description: Text("Settings is not done and currently is in this state.")
                )
                .listRowBackground(Color.clear)

                Section("Info") {
                    LabeledContent {
                        Text(sysVer)
                    } label: {
                        Label("iOS Version", systemImage: "iphone")
                    }
                    LabeledContent {
                        Text(sysBuildNum)
                    } label: {
                        Label("iOS Build Version", systemImage: "hammer.fill")
                    }
                }

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
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
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
        .presentationDetents([.large])
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
        "App",
        systemImage: "moon.stars.fill",
        description: Text("""
                          Some things are here for the app. Come back in the next update for more features.
                          
                          Current Version: 1.1
                          """)
    )

    Button(action: {
    // Button action here
}) {
    Text("Button :)")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.vertical, 14)
        .padding(.horizontal, 28)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                
                Capsule()
                    .fill(.blue.opacity(0.85))
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 6)
}
.tint(.blue)
    .padding(.top, 16)
}
            .navigationTitle("App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    MainTabView()
}
