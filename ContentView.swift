import SwiftUI
import Combine

// MARK: - Reálná Nativní Telemetrie & Diagnostika Zařízení 🛡️📱
class RealSystemAdminManager: ObservableObject {
    @Published var batteryLevel: Int = 0
    @Published var batteryState: String = "Neznámý"
    @Published var freeStorageGB: Double = 0.0
    @Published var totalStorageGB: Double = 0.0
    @Published var appMemoryMB: Double = 0.0
    @Published var totalDeviceRAMGB: Double = 0.0
    @Published var thermalStateName: String = "Normální 🟢"
    @Published var thermalColor: Color = .green
    @Published var systemUptime: String = "0h 0m 0s"
    @Published var actionMessage: String? = nil

    // Informace o aplikaci & iOS ℹ️
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    let bundleID = Bundle.main.bundleIdentifier ?? "com.local.app"
    let deviceModel = UIDevice.current.model
    let systemVersion = UIDevice.current.systemVersion
    let deviceName = UIDevice.current.name

    private var timer: Timer?

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        fetchRealDeviceMetrics()
        startTelemetryLoop()
    }

    // Čtení reálných dat z hardware zařízení ⚡
    func fetchRealDeviceMetrics() {
        // 1. Reálná baterie 🔋
        let rawLevel = UIDevice.current.batteryLevel
        self.batteryLevel = rawLevel >= 0 ? Int(rawLevel * 100) : 100
        
        switch UIDevice.current.batteryState {
        case .charging: self.batteryState = "Nabíjí se ⚡"
        case .full: self.batteryState = "Plně nabito 🔌"
        case .unplugged: self.batteryState = "Na baterii 🔋"
        default: self.batteryState = "Neznámý ❓"
        }

        // 2. Skutečné úložiště disku 💾
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        if let values = try? homeURL.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]) {
            if let free = values.volumeAvailableCapacity, let total = values.volumeTotalCapacity {
                self.freeStorageGB = Double(free) / 1_073_741_824.0
                self.totalStorageGB = Double(total) / 1_073_741_824.0
            }
        }

        // 3. Reálná spotřeba RAM paměti aplikace 🧠
        var stats = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            self.appMemoryMB = Double(stats.resident_size) / 1024.0 / 1024.0
        }
        self.totalDeviceRAMGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0

        // 4. Teplota / Thermal State zařízení 🌡️
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            self.thermalStateName = "Normální 🟢"
            self.thermalColor = .green
        case .fair:
            self.thermalStateName = "Mírně teplé 🟡"
            self.thermalColor = .yellow
        case .serious:
            self.thermalStateName = "Horké 🟠"
            self.thermalColor = .orange
        case .critical:
            self.thermalStateName = "Kritické 🔴"
            self.thermalColor = .red
        @unknown default:
            self.thermalStateName = "Neznámé ⚪"
            self.thermalColor = .gray
        }

        // 5. Reálný Uptime systému ⏱️
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        self.systemUptime = String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }

    private func startTelemetryLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.fetchRealDeviceMetrics()
            }
        }
    }

    // 🧹 Skutečné vyčištění Cache složky z paměti telefonu!
    func clearRealCache() {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            fetchRealDeviceMetrics()
            showAction("Složka Cache byla smazána z disku! 🧹💾")
        } catch {
            showAction("Chyba při mazání cache: \(error.localizedDescription) ⚠️")
        }
    }

    // 📳 Vyvolání haptické odezvy zařízení
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showAction("Haptický motor aktivován! 📳✨")
    }

    private func showAction(_ text: String) {
        withAnimation {
            self.actionMessage = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                self.actionMessage = nil
            }
        }
    }
}

// MARK: - Hlavní Kontajner Aplikace 📱
struct ContentView: View {
    @StateObject private var adminManager = RealSystemAdminManager()

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
    @EnvironmentObject var adminManager: RealSystemAdminManager
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
            // Ikony Admin Panelu 🛡️ i Nastavení ⚙️ vpravo nahoře!
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: AdminPanelView()) {
                        Image(systemName: "shield.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
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

// MARK: - Admin Panel View (Skutečná Diagnostika) 🛡️👑
struct AdminPanelView: View {
    @EnvironmentObject var adminManager: RealSystemAdminManager

    var body: some View {
        List {
            // Oznámení o provedené akci 🔔
            if let msg = adminManager.actionMessage {
                Section {
                    Text(msg)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // MARK: - Reálný Stav Hardware ⚡
            Section(header: Text("Reálný Stav Zařízení 📊")) {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        MetricCard(title: "Baterie", value: "\(adminManager.batteryLevel)%", icon: "battery.100", color: adminManager.batteryLevel > 20 ? .green : .red)
                        MetricCard(title: "Volné Místo", value: String(format: "%.1f GB", adminManager.freeStorageGB), icon: "internaldrive", color: .blue)
                    }
                    GridRow {
                        MetricCard(title: "RAM Aplikace", value: String(format: "%.1f MB", adminManager.appMemoryMB), icon: "memorychip", color: .purple)
                        MetricCard(title: "Teplota HW", value: adminManager.thermalStateName, icon: "thermometer.medium", color: adminManager.thermalColor)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            // MARK: - Informace o Systému & Telefonu 📱
            Section(header: Text("Systémové Informace ℹ️")) {
                HStack {
                    Label("Název Zařízení 📱", systemImage: "iphone")
                    Spacer()
                    Text(adminManager.deviceName).foregroundStyle(.secondary)
                }
                HStack {
                    Label("Verze iOS 🍏", systemImage: "apple.logo")
                    Spacer()
                    Text("iOS \(adminManager.systemVersion)").foregroundStyle(.secondary)
                }
                HStack {
                    Label("Stav Baterie 🔌", systemImage: "bolt.fill")
                    Spacer()
                    Text(adminManager.batteryState).foregroundStyle(.secondary)
                }
                HStack {
                    Label("Uptime Telefonu ⏱️", systemImage: "clock.fill")
                    Spacer()
                    Text(adminManager.systemUptime).bold().monospacedDigit()
                }
                HStack {
                    Label("Celková RAM HW 🧠", systemImage: "cpu")
                    Spacer()
                    Text(String(format: "%.1f GB RAM", adminManager.totalDeviceRAMGB)).foregroundStyle(.secondary)
                }
                HStack {
                    Label("Celková Kapacita 💾", systemImage: "sdcard")
                    Spacer()
                    Text(String(format: "%.1f GB", adminManager.totalStorageGB)).foregroundStyle(.secondary)
                }
            }

            // MARK: - Informace o Aplikaci 📦
            Section(header: Text("Metadata Buildu 📦")) {
                HStack {
                    Label("Bundle ID 🆔", systemImage: "shippingbox")
                    Spacer()
                    Text(adminManager.bundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Verze Aplikace 🏷️", systemImage: "tag.fill")
                    Spacer()
                    Text("\(adminManager.appVersion) (\(adminManager.buildNumber))").foregroundStyle(.secondary)
                }
            }

            // MARK: - Reálné Správcovské Akce 🚀
            Section(header: Text("Nativní Akce 🛠️")) {
                Button(action: {
                    adminManager.clearRealCache()
                }) {
                    Label("Smazat Reálnou Cache z Disku 🧹", systemImage: "trash.fill")
                        .foregroundColor(.red)
                }

                Button(action: {
                    adminManager.triggerHapticFeedback()
                }) {
                    Label("Test Haptiky (Vibrace) 📳", systemImage: "waveform")
                }

                Button(action: {
                    adminManager.fetchRealDeviceMetrics()
                }) {
                    Label("Obnovit Telemetrii 🔄", systemImage: "arrow.clockwise")
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
                .font(.title3)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
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
