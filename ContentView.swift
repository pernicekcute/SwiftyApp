import SwiftUI
import Foundation
import Security

// MARK: - Certificate Manager
class CertificateManager: ObservableObject {
    @Published var isImported: Bool = false
    @Published var isValid: Bool = false
    @Published var showInvalidAlert: Bool = false
    
    private let certKey = "stored_p12_certificate_data"
    private let passwordKey = "stored_p12_password"
    
    init() {
        checkStoredCertificate()
    }
    
    func checkStoredCertificate() {
        if let certData = UserDefaults.default?.data(forKey: certKey) {
            isImported = true
            validateCertificateData(certData, password: UserDefaults.default?.string(forKey: passwordKey) ?? "")
        } else {
            isImported = false
            isValid = false
        }
    }
    
    func saveAndValidateCertificate(data: Data, password: String) {
        let options: [String: Any] = [kSecImportExportPassphrase as String: password]
        var rawItems: CFArray?
        
        let status = SecPKCS12Import(data as CFData, options as CFDictionary, &rawItems)
        
        if status == errSecSuccess, let items = rawItems as? [[String: Any]], let item = items.first {
            // Valid .p12 certificate successfully parsed
            UserDefaults.default?.set(data, forKey: certKey)
            UserDefaults.default?.set(password, forKey: passwordKey)
            isImported = true
            isValid = true
            showInvalidAlert = false
        } else {
            // Invalid certificate or wrong password
            isImported = false
            isValid = false
            showInvalidAlert = true
        }
    }
    
    private func validateCertificateData(_ data: Data, password: String) {
        let options: [String: Any] = [kSecImportExportPassphrase as String: password]
        var rawItems: CFArray?
        let status = SecPKCS12Import(data as CFData, options as CFDictionary, &rawItems)
        
        if status == errSecSuccess {
            isValid = true
        } else {
            isValid = false
            showInvalidAlert = true
        }
    }
    
    func clearCertificate() {
        UserDefaults.default?.removeObject(forKey: certKey)
        UserDefaults.default?.removeObject(forKey: passwordKey)
        isImported = false
        isValid = false
    }
}

// MARK: - Dynamic App Background
struct AppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.38, green: 0.15, blue: 0.08),
                    Color(red: 0.18, green: 0.08, blue: 0.28)
                  ]
                : [Color(red: 1.00, green: 0.88, blue: 0.70), Color(red: 1.00, green: 0.98, blue: 0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Reusable Centered Toolbar Button
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

// MARK: - Reusable Centered Toolbar Button
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

struct ExitToolbarButton: View {
    private func exitToHomeScreen() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            exit(0)
        }
    }
    
    var body: some View {
        Button {
            exitToHomeScreen()
        } label: {
            Image(systemName: "xmark")
                .frame(width: 36, height: 36)
        }
    }
}

// MARK: - Tab Enum
enum AppTab: Hashable, Identifiable, CaseIterable {
    case global
    case second
    case third
    case fourth
    case experiments
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .global: return "Global"
        case .second: return "Local"
        case .third: return "Exploits"
        case .fourth: return "Other"
        case .experiments: return "Experiments"
        }
    }
    
    var icon: String {
        switch self {
        case .global: return "globe"
        case .second: return "iphone"
        case .third: return "cpu.fill"
        case .fourth: return "book"
        case .experiments: return "flask.fill"
        }
    }
}

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

// MARK: - Form Row Component
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

// MARK: - Native Apple NavigationSplitView Sidebar
struct MainTabView: View {
    @AppStorage("hasAgreedToTerms") private var hasAgreedToTerms: Bool = false
    @StateObject private var certManager = CertificateManager()
    @State private var selectedTab: AppTab? = .global
    @State private var showSearchSheet: Bool = false
    @State private var showBetaAlert: Bool = false

    var body: some View {
        NavigationSplitView {
            List(AppTab.allCases, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.title, systemImage: tab.icon)
                }
            }
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
            certManager.checkStoredCertificate()
        }
        .alert("App is in Release", isPresented: $showBetaAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This app is currently released but some features may change or be incomplete.")
        }
        .alert("Invalid certificate, please import a valid one.", isPresented: $certManager.showInvalidAlert) {
            Button("OK", role: .cancel) { }
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
        case .experiments:
            ExperimentsTabView()
        }
    }
}

// MARK: - 1st Page: Global
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                CustomToolbarButton()
                ExitToolbarButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ChangelogBtn()
                Button { showSettingsSheet = true } label: { Image(systemName: "gear") }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsSheetView() }
    }
}

// MARK: - 2nd Page: Local
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                CustomToolbarButton()
                ExitToolbarButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ChangelogBtn()
                Button { showSettingsSheet = true } label: { Image(systemName: "gear") }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsSheetView() }
    }
}

// MARK: - 3rd Page: Exploits
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                CustomToolbarButton()
                ExitToolbarButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ChangelogBtn()
                Button { showSettingsSheet = true } label: { Image(systemName: "gear") }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsSheetView() }
    }
}

// MARK: - 4th Page: Other
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                CustomToolbarButton()
                ExitToolbarButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ChangelogBtn()
                Button { showSettingsSheet = true } label: { Image(systemName: "gear") }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsSheetView() }
    }
}

// MARK: - 5th Page: Experiments
struct ExperimentsTabView: View {
    @State private var showSettingsSheet = false
    @State private var selectedActionText: String = "Select an option from the menu"

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 24) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
                
                Text("Experiments")
                    .font(.title2)
                    .bold()

                // Dropdown Menu Button
                Menu {
                    Button {
                        selectedActionText = "Option One Selected"
                    } label: {
                        Label("Option One", systemImage: "1.circle")
                    }

                    Button {
                        selectedActionText = "Option Two Selected"
                    } label: {
                        Label("Option Two", systemImage: "2.circle")
                    }

                    Divider()

                    Menu {
                        Button("Sub Option A") {
                            selectedActionText = "Option Three -> Sub Option A Selected"
                        }
                        Button("Sub Option B") {
                            selectedActionText = "Option Three -> Sub Option B Selected"
                        }
                    } label: {
                        Label("Option Three", systemImage: "3.circle")
                    }
                } label: {
                    Label("Actions", systemImage: "chevron.down.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.glass)

                Text(selectedActionText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Experiments")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                CustomToolbarButton()
                ExitToolbarButton()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ChangelogBtn()
                Button { showSettingsSheet = true } label: { Image(systemName: "gear") }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsSheetView() }
    }
}

// MARK: - Settings Sheet View
struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var buttonTitle: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var showFileImporter: Bool = false
    @State private var certPassword: String = ""
    @State private var pendingCertData: Data? = nil
    @State private var showPasswordPrompt: Bool = false

    @StateObject private var certManager = CertificateManager()

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
                    Section("Certificate Status") {
                        HStack {
                            Label("Certificate", systemImage: certManager.isValid ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            Spacer()
                            Text(certManager.isValid ? "Certificate Imported!" : "Import a valid certificate.")
                                .foregroundStyle(certManager.isValid ? .green : .red)
                        }
                        
                        Button(certManager.isValid ? "Change .p12 Certificate" : "Import .p12 Certificate") {
                            showFileImporter = true
                        }
                        
                        if certManager.isValid {
                            Button("Remove Certificate", role: .destructive) {
                                certManager.clearCertificate()
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.15))

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
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        do {
                            let data = try Data(contentsOf: url)
                            pendingCertData = data
                            showPasswordPrompt = true
                        } catch {
                            certManager.showInvalidAlert = true
                        }
                    }
                case .failure(_):
                    certManager.showInvalidAlert = true
                }
            }
            .alert("Enter .p12 Password", isPresented: $showPasswordPrompt) {
                SecureField("Password", text: $certPassword)
                Button("Import") {
                    if let data = pendingCertData {
                        certManager.saveAndValidateCertificate(data: data, password: certPassword)
                    }
                    certPassword = ""
                    pendingCertData = nil
                }
                Button("Cancel", role: .cancel) {
                    certPassword = ""
                    pendingCertData = nil
                }
            } message: {
                Text("Please enter the password for the selected .p12 certificate file.")
            }
            .alert("Invalid certificate, please import a valid one.", isPresented: $certManager.showInvalidAlert) {
                Button("OK", role: .cancel) { }
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

// MARK: - Custom Search Sheet View
struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
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

#Preview {
    MainTabView()
}
