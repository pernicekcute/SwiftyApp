import SwiftUI
import Combine

// MARK: - Reálný Správce Systému & Admin Dat 🛡️📊
class AdminManager: ObservableObject {
    @Published var userCount: Int = 1248
    @Published var uptimeSeconds: Int = 86400
    @Published var cpuUsage: Double = 32.0
    @Published var errorCount: Int = 0
    @Published var debugLogs: Bool = true
    @Published var selectedServer: String = "EU-Central"
    @Published var apiRateLimit: Double = 250.0
    @Published var auditLogs: [AuditLog] = []
    
    @Published var maintenanceMode: Bool = false {
        didSet {
            addLog(
                title: maintenanceMode ? "Režim údržby ZAPNUT 🛠️" : "Režim údržby VYPNUT 🟢",
                type: maintenanceMode ? .warning : .info
            )
        }
    }

    private var timer: Timer?

    init() {
        // Výchozí logy 📝
        auditLogs = [
            AuditLog(title: "Záloha databáze dokončena 💾", timestamp: "Dnes, 08:15", type: .success),
            AuditLog(title: "Nový Admin přidán: Shadow_ROBLOX 👨‍💻", timestamp: "Včera, 22:40", type: .info)
        ]
        startLiveSimulation()
    }

    // Živá simulace měnících se dat (CPU, Uptime, Uživatelé) 🔄
    private func startLiveSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.uptimeSeconds += 2
                self.cpuUsage = Double.random(in: 18...42).rounded()
                if Int.random(in: 1...4) == 2 {
                    self.userCount += Int.random(in: -1...3)
                }
            }
        }
    }

    func addLog(title: String, type: AuditLog.LogType) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeStr = "Dnes, " + formatter.string(from: Date())
        let newLog = AuditLog(title: title, timestamp: timeStr, type: type)
        auditLogs.insert(newLog, at: 0)
    }

    func clearCache() {
        addLog(title: "Databázová cache byla vyčištěna 🔄", type: .info)
    }

    func clearLogs() {
        auditLogs.removeAll()
        addLog(title: "Audit logy byly vymazány 🧹", type: .warning)
    }

    func restartServer() {
        cpuUsage = 5.0
        errorCount = 0
        addLog(title: "Server byl restartován administrátorem ⚠️", type: .error)
    }

    var formattedUptime: String {
        let hours = uptimeSeconds / 3600
        let minutes = (uptimeSeconds % 3600) / 60
        let secs = uptimeSeconds % 60
        return String(format: "%02dh %02dm %02ds", hours, minutes, secs)
    }
}

// MARK: - Model Logu 📜
struct AuditLog: Identifiable {
    let id = UUID()
    let title: String
    let timestamp: String
    let type: LogType

    enum LogType {
        case info, success, warning, error

        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            }
        }
    }
}

// MARK: - Hlavní Kontajner Aplikace 📱
struct ContentView: View {
    @StateObject private var adminManager = AdminManager()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Domů", systemImage: "house.fill")
            }
            
            NavigationStack {
                CreditsView()
            }
            .tabItem {
                Label("Kredity", systemImage: "heart.text.square.fill")
            }
        }
        .environmentObject(adminManager)
    }
}

// MARK: - Home View 🏠
struct HomeView: View {
    @EnvironmentObject var adminManager: AdminManager
    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Ikona v záhlaví 🖼️
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.gray)

                // Přepínač / Toggle 🎚️
                Toggle(isOn: $isToggleOn) {
                    Label("Přepínač", systemImage: "switch.2")
                        .font(.headline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Posuvník / Slider 🎛️
                VStack(alignment: .leading, spacing: 10) {
                    Label("Hodnota posuvníku: \(Int(sliderValue))", systemImage: "slider.horizontal.3")
                        .font(.headline)
                    Slider(value: $sliderValue, in: 0...100)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Indikátor načítání 🌀
                VStack(spacing: 10) {
                    Label("Načítání", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                    
                    if isLoading {
                        ProgressView()
                            .controlSize(.large)
                    } else {
                        Text("Stiskněte tlačítko níže pro spuštění")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Tlačítko 👆
                Button(action: {
                    withAnimation {
                        isLoading.toggle()
                    }
                }) {
                    Label(isLoading ? "Zastavit" : "Spustit", systemImage: isLoading ? "stop.fill" : "play.fill")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Domů")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Obě ikony vpravo nahoře v jednom HStacku! 🔝🛡️⚙️
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: AdminPanelView()) {
                        Image(systemName: "shield.gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Admin Panel View 🛡️👑
struct AdminPanelView: View {
    @EnvironmentObject var adminManager: AdminManager
    @State private var newAdminName: String = ""

    var body: some View {
        List {
            // MARK: - Živá Metrika 📊
            Section(header: Text("Živý Systémový Přehled 📈")) {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        MetricCard(title: "Aktivní Uživatelé", value: "\(adminManager.userCount)", icon: "person.3.fill", color: .blue)
                        MetricCard(title: "Uptime", value: adminManager.formattedUptime, icon: "server.rack", color: .green)
                    }
                    GridRow {
                        MetricCard(title: "Zátěž CPU", value: "\(Int(adminManager.cpuUsage))%", icon: "cpu", color: adminManager.cpuUsage > 35 ? .orange : .green)
                        MetricCard(title: "Chyby", value: "\(adminManager.errorCount)", icon: "exclamationmark.triangle.fill", color: adminManager.errorCount > 0 ? .red : .gray)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            // MARK: - Správa Serveru & Údržba 🎛️
            Section(header: Text("Správa Systému 🎛️")) {
                Toggle(isOn: $adminManager.maintenanceMode) {
                    Label("Režim údržby 🛠️", systemImage: "wrench.and.screwdriver.fill")
                }
                
                Toggle(isOn: $adminManager.debugLogs) {
                    Label("Podrobné Logování 📜", systemImage: "terminal.fill")
                }

                Picker("Aktivní Server 🌐", selection: $adminManager.selectedServer) {
                    Text("EU-Central (Praha) 🇨🇿").tag("EU-Central")
                    Text("US-East (Virginia) 🇺🇸").tag("US-East")
                    Text("AP-East (Tokyo) 🇯🇵").tag("AP-East")
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("API Rate Limit ⚡", systemImage: "speedometer")
                        Spacer()
                        Text("\(Int(adminManager.apiRateLimit)) req/min")
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $adminManager.apiRateLimit, in: 50...1000, step: 50)
                }
                .padding(.vertical, 4)
            }

            // MARK: - Přidání nového Admina 👨‍💻
            Section(header: Text("Přidat Správce 👤")) {
                HStack {
                    TextField("Jméno nového admina...", text: $newAdminName)
                    Button("Přidat") {
                        guard !newAdminName.isEmpty else { return }
                        adminManager.addLog(title: "Nový admin přidal: \(newAdminName) 👨‍💻", type: .info)
                        newAdminName = ""
                    }
                    .bold()
                    .disabled(newAdminName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            // MARK: - Rychlé Admin Akce ⚡
            Section(header: Text("Akce Serveru 🚀")) {
                Button(action: {
                    adminManager.clearCache()
                }) {
                    Label("Obnovit Databázovou Cache 🔄", systemImage: "arrow.clockwise.circle.fill")
                }

                Button(action: {
                    adminManager.clearLogs()
                }) {
                    Label("Vymazat Logy 🧹", systemImage: "trash.fill")
                }

                Button(role: .destructive, action: {
                    adminManager.restartServer()
                }) {
                    Label("Restartovat Server ⚠️", systemImage: "power")
                }
            }

            // MARK: - Živý Audit Log 📝
            Section(header: Text("Živý Audit Log (\(adminManager.auditLogs.count)) 📜")) {
                if adminManager.auditLogs.isEmpty {
                    Text("Žádné záznamy v logu")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(adminManager.auditLogs) { log in
                        HStack(spacing: 12) {
                            Image(systemName: log.type.icon)
                                .foregroundColor(log.type.color)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(log.timestamp)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Admin Panel 🛡️")
        .navigationBarTitleDisplayMode(.inline)
        // 🙈 Skryje spodní TabView po dobu návštěvy Admin Panelu!
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Kartička Metriky 🖼️
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Settings View ⚙️
struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)

            Text("Nastavení")
                .font(.largeTitle)
                .bold()

            Text("Tohle je stránka nastavení aplikace! ⚙️✨")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.inline)
        // 🙈 Skryje spodní TabView po dobu návštěvy Nastavení!
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Credits View 💖
struct CreditsView: View {
    var body: some View {
        List {
            // MARK: - Hlavička s logem 📱✨
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.tint)
                        .shadow(radius: 4)
                    
                    Text("iOsApp")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
            }
            
            // MARK: - Tým & Vývojáři 👨‍💻👩‍💻
            Section(header: Text("Tým")) {
                HStack {
                    Label("Vývojář", systemImage: "hammer.fill")
                    Spacer()
                    Text("iOSondyhop ")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("UI/UX Design", systemImage: "paintpalette")
                    Spacer()
                    Text("Shadow_ROBLOX")
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Použité knihovny & Poděkování 📚🙏
            Section(header: Text("Poděkování a open-source")) {
                Link(destination: URL(string: "https://github.com")!) {
                    HStack {
                        Label("Open-Source knihovny", systemImage: "shippingbox.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Link(destination: URL(string: "https://developer.apple.com/sf-symbols/")!) {
                    HStack {
                        Label("SF Symbols", systemImage: "star.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            // MARK: - Odkazy & Kontakt 🌐📧
            Section(header: Text("Kde nás najdete")) {
                Link(destination: URL(string: "https://example.com")!) {
                    Label("Oficiální web", systemImage: "globe")
                }
                
                Link(destination: URL(string: "mailto:pernicekcute@gmail.com")!) {
                    Label("Napsat na podporu", systemImage: "envelope.fill")
                }
            }
            
            // MARK: - Copyright 📜
            Section {
                HStack {
                    Spacer()
                    Text("© 2026 Všechna práva vyhrazena")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Kredity")
        .navigationBarTitleDisplayMode(.inline)
    }
}
