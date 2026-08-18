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

// MARK: - Home View 🏠✨ Liquid Glass Playground
struct HomeView: View {
    @EnvironmentObject var adminManager: RealSystemAdminManager

    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var isLoading = false
    @State private var isPressed = false

    var body: some View {
        ScrollView {
            GlassEffectContainer(spacing: 20) {
                VStack(spacing: 20) {

                    // MARK: - Hero Glass Element ✨
                    VStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(.tint)
                            .frame(width: 86, height: 86)
                            .glassEffect(
                                .regular.tint(.blue.opacity(0.35)),
                                in: .circle
                            )

                        VStack(spacing: 4) {
                            Text("Liquid Glass")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("Interaktivní playground")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                    // MARK: - Toggle Glass Card 🎚️
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Přepínač", systemImage: "switch.2")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(isToggleOn ? "Aktivní" : "Neaktivní")
                                    .fontWeight(.medium)

                                Text(isToggleOn
                                     ? "Funkce je zapnutá"
                                     : "Funkce je vypnutá")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $isToggleOn)
                                .labelsHidden()
                                .tint(.blue)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(
                        .regular.tint(
                            isToggleOn
                            ? .blue.opacity(0.25)
                            : .clear
                        ),
                        in: .rect(cornerRadius: 28)
                    )

                    // MARK: - Slider Glass Card 🎛️
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(
                                "Posuvník",
                                systemImage: "slider.horizontal.3"
                            )
                            .font(.headline)

                            Spacer()

                            Text("\(Int(sliderValue))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .glassEffect(
                                    .regular.tint(.purple.opacity(0.25)),
                                    in: .capsule
                                )
                        }

                        Slider(
                            value: $sliderValue,
                            in: 0...100
                        )
                        .tint(.purple)

                        HStack {
                            Text("0")
                            Spacer()
                            Text("100")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .glassEffect(
                        .regular.tint(.purple.opacity(0.15)),
                        in: .rect(cornerRadius: 28)
                    )

                    // MARK: - Loading Glass Card 🌀
                    VStack(spacing: 14) {
                        Image(systemName: isLoading
                              ? "arrow.triangle.2.circlepath"
                              : "checkmark.circle")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                isLoading ? .orange : .green
                            )
                            .symbolEffect(
                                .rotate,
                                isActive: isLoading
                            )

                        Text(isLoading
                             ? "Probíhá operace…"
                             : "Připraveno")
                            .font(.headline)

                        Text(isLoading
                             ? "Liquid Glass pracuje."
                             : "Stiskni tlačítko níže pro spuštění.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        if isLoading {
                            ProgressView()
                                .controlSize(.large)
                                .tint(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .glassEffect(
                        .regular.tint(
                            isLoading
                            ? .orange.opacity(0.18)
                            : .green.opacity(0.12)
                        ),
                        in: .rect(cornerRadius: 30)
                    )

                    // MARK: - Main Liquid Glass Button 🚀
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            isLoading.toggle()
                        }
                    } label: {
                        Label(
                            isLoading ? "Zastavit" : "Spustit",
                            systemImage: isLoading
                                ? "stop.fill"
                                : "play.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(isLoading ? .red : .blue)
                    .controlSize(.large)

                    // MARK: - Quick Glass Actions ⚡
                    HStack(spacing: 14) {

                        Button {
                            adminManager.triggerHapticFeedback()
                        } label: {
                            Image(systemName: "waveform")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 58, height: 58)

                        Button {
                            adminManager.fetchRealDeviceMetrics()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 58, height: 58)

                        NavigationLink {
                            AdminPanelView()
                        } label: {
                            Image(systemName: "shield.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 58, height: 58)

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 58, height: 58)
                    }

                    // MARK: - Device Status Glass Pill 📱
                    HStack(spacing: 10) {
                        Circle()
                            .fill(adminManager.thermalColor)
                            .frame(width: 9, height: 9)
                            .shadow(
                                color: adminManager.thermalColor.opacity(0.7),
                                radius: 5
                            )

                        Text(adminManager.thermalStateName)

                        Spacer()

                        Text("\(adminManager.batteryLevel)%")
                            .fontWeight(.semibold)
                            .monospacedDigit()

                        Image(
                            systemName: adminManager.batteryLevel > 20
                                ? "battery.75percent"
                                : "battery.25percent"
                        )
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 13)
                    .glassEffect(
                        .regular.tint(.green.opacity(0.12)),
                        in: .capsule
                    )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .scrollIndicators(.hidden)
        .background {
            // Jemný živý gradient pod sklem
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.10),
                    Color.purple.opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Domů")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AdminPanelView()
                } label: {
                    Image(systemName: "shield.fill")
                }
                .buttonStyle(.glass)
            }
        }
    }
}

// MARK: - Admin Panel View (Skutečná Diagnostika) 🛡️👑
struct AdminPanelView: View {
    @EnvironmentObject var adminManager: RealSystemAdminManager

    var body: some View {
        List {
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
        .navigationTitle("Nastavení ⚙️")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Credits View 💖
struct CreditsView: View {
    var body: some View {
        List {
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
            
            Section(header: Text("Kde nás najdete")) {
                Link(destination: URL(string: "https://example.com")!) {
                    Label("Oficiální web", systemImage: "globe")
                }
                
                Link(destination: URL(string: "mailto:pernicekcute@gmail.com")!) {
                    Label("Napsat na podporu", systemImage: "envelope.fill")
                }
            }
            
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
