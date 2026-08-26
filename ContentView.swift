import SwiftUI
import Foundation

// MARK: - Dynamic App Background
struct AppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.38, green: 0.15, blue: 0.08), Color(red: 0.18, green: 0.08, blue: 0.28)]
                : [Color(red: 1.00, green: 0.88, blue: 0.70), Color(red: 1.00, green: 0.98, blue: 0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Reusable Toolbar Items
struct CustomToolbarButton: View {
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "person.fill")
                .frame(width: 36, height: 36)
        }
        .sheet(isPresented: $showSheet) {
            TestSheet()
        }
    }
}

struct ChangelogBtn: View {
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            Image(systemName: "doc.text.fill")
                .frame(width: 36, height: 36)
        }
        .sheet(isPresented: $showSheet) {
            ChangelogSheet()
        }
    }
}

// MARK: - Shared Toolbar Modifier (DRY Refactor)
struct StandardToolbarModifier: ViewModifier {
    @Binding var showSettingsSheet: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    CustomToolbarButton()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ChangelogBtn()
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

extension View {
    func standardToolbar(showSettingsSheet: Binding<Bool>) -> some View {
        self.modifier(StandardToolbarModifier(showSettingsSheet: showSettingsSheet))
    }
}

// MARK: - Tab Enum
enum AppTab: Hashable, Identifiable, CaseIterable {
    case global
    case second
    case third
    case fourth
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .global: return "Global"
        case .second: return "Local"
        case .third: return "Exploits"
        case .fourth: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .global: return "globe"
        case .second: return "iphone"
        case .third: return "cpu.fill"
        case .fourth: return "book"
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @AppStorage("hasAgreedToTerms") private var hasAgreedToTerms: Bool = false
    @State private var selectedTab: AppTab? = .global
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var showSearchSheet: Bool = false
    @State private var showBetaAlert: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(AppTab.allCases, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.title, systemImage: tab.icon)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Pages")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showSearchSheet = true
                    } label: {
                        Label("App Info", systemImage: "moon.stars.fill")
                    }
                    .tint(.orange)
                }
            }
        } detail: {
            NavigationStack {
                currentContentView
            }
        }
        .accentColor(.orange)
        .sheet(isPresented: $showSearchSheet) {
            SearchSheetView()
        }
        .onAppear {
            if !hasAgreedToTerms {
                showBetaAlert = true
            }
        }
        .alert("App is in Release", isPresented: $showBetaAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This app is currently released but some features may change or be incomplete.")
        }
    }

    @ViewBuilder
    private var currentContentView: some View {
        switch selectedTab {
        case .global, .none:
            GlobalView()
        case .second:
            SecondTabView()
        case .third:
            ExploitsTabView()
        case .fourth:
            OtherTabView()
        }
    }
}

// MARK: - Views
struct GlobalView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 12) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                    .font(.title2)
                    .bold()
            }
            .padding()
        }
        .navigationTitle("Global")
        .standardToolbar(showSettingsSheet: $showSettingsSheet)
    }
}

struct SecondTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 12) {
                Image(systemName: "iphone")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, user!")
                    .font(.title2)
                    .bold()
            }
            .padding()
        }
        .navigationTitle("Local")
        .standardToolbar(showSettingsSheet: $showSettingsSheet)
    }
}

struct ExploitsTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        ZStack {
            AppBackgroundView()
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
                        .background(.thinMaterial)
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
                        .background(.thinMaterial)
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
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Info about Exploits")
        .standardToolbar(showSettingsSheet: $showSettingsSheet)
    }
}

struct OtherTabView: View {
    @State private var showSettingsSheet = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 12) {
                Image(systemName: "book")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Nothing here yet!")
                    .font(.title2)
                    .bold()
            }
            .padding()
        }
        .navigationTitle("Other")
        .standardToolbar(showSettingsSheet: $showSettingsSheet)
    }
}

// MARK: - Sheets
struct TestSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                Form {
                    Section("Credits - YouTube") {
                        CreditFormRow(
                            handle: "@ondyhop_verity",
                            description: "Main Developer",
                            avatarURL: "https://unavatar.io/youtube/ondyhop_verity",
                            fallbackIcon: "hammer.fill"
                        )
                        CreditFormRow(
                            handle: "@SHADOW_ROBLOX_RIVALS",
                            description: "Co-Developer",
                            avatarURL: "https://unavatar.io/youtube/SHADOW_ROBLOX_RIVALS",
                            fallbackIcon: "hammer"
                        )
                    }

                    Section("Credits - TikTok") {
                        CreditFormRow(
                            handle: "@rockyroad_doors",
                            description: "UI Helper",
                            avatarURL: "https://yt3.googleusercontent.com/Qyn1kwTNzit7rXSf9YlEASLZwmuC3O8WaENFR68c3WMkDUHrIjNMYWRyZwwYsO7KyUgjV2PpYsk=s800-c-k-c0x00ffffff-no-rj",
                            fallbackIcon: "hammer.fill"
                        )
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Image(systemName: "checkmark") }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct ChangelogSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                ContentUnavailableView(
                    "Changelog",
                    systemImage: "doc.text.fill",
                    description: Text("Changelog is not done and currently is in this state.")
                )
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Changelog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Image(systemName: "checkmark") }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var buttonTitle: String = ""
    @State private var isShowingAlert: Bool = false

    private var sysVer: String { UIDevice.current.systemVersion }

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
            ZStack {
                AppBackgroundView()
                Form {
                    ContentUnavailableView(
                        "Settings",
                        systemImage: "gear",
                        description: Text("Settings is not done and currently is in this state.")
                    )
                    .listRowBackground(Color.clear)

                    Section("Info") {
                        LabeledContent { Text(sysVer) } label: { Label("iOS Version", systemImage: "iphone") }
                        LabeledContent { Text(sysBuildNum) } label: { Label("iOS Build Version", systemImage: "hammer.fill") }
                    }
                    .listRowBackground(Color.white.opacity(0.15))

                    Section("Dialog Inputs") {
                        TextField("Title", text: $title)
                        TextField("Message", text: $message)
                        TextField("Button Label", text: $buttonTitle)
                    }
                    .listRowBackground(Color.white.opacity(0.15))

                    Section {
                        Button("Show Dialog") { isShowingAlert = true }
                    }
                    .listRowBackground(Color.white.opacity(0.15))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Image(systemName: "checkmark") }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
            }
            .alert(title.isEmpty ? "Alert" : title, isPresented: $isShowingAlert) {
                Button(buttonTitle.isEmpty ? "OK" : buttonTitle) { }
            } message: {
                if !message.isEmpty { Text(message) }
            }
        }
        .presentationDetents([.large])
    }
}

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack {
                    ContentUnavailableView(
                        "App",
                        systemImage: "moon.stars.fill",
                        description: Text("Some things are here for the app. Come back in the next update for more features.\n\nCurrent Version: 1.3")
                    )

                    Button(action: {}) { Text("Button :)") }
                        .padding(.top, 4)
                    .buttonStyle(.glass)
                }
            }
            .navigationTitle("App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Image(systemName: "checkmark") }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct CreditFormRow: View {
    let handle: String
    let description: String
    let avatarURL: String
    let fallbackIcon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: avatarURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Image(systemName: fallbackIcon)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue.gradient)
                @unknown default:
                    ProgressView()
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(handle)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainTabView()
}
