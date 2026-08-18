import SwiftUI
import UIKit
import Darwin
import MachO

// MARK: - Chybějící Glass Komponenty 🪟✨

struct GlassMaterial {
    var tint: Color = .clear
    
    static var regular: GlassMaterial { GlassMaterial() }
    
    func tint(_ color: Color) -> GlassMaterial {
        var copy = self
        copy.tint = color
        return copy
    }
}

extension View {
    func glassEffect<S: Shape>(_ material: GlassMaterial, in shape: S) -> some View {
        self.background(.ultraThinMaterial, in: shape)
            .background(material.tint, in: shape)
            .overlay(shape.stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct GlassProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.accentColor.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}

extension ButtonStyle where Self == GlassProminentButtonStyle {
    static var glassProminent: GlassProminentButtonStyle { GlassProminentButtonStyle() }
}

struct GlassEffectContainer<Content: View>: View {
    var spacing: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: spacing) {
            content()
        }
    }
}

// MARK: - Reálná Nativní Telemetrie & Diagnostika Zařízení 🛡️📱

@MainActor
final class RealSystemAdminManager: ObservableObject {

    @Published var batteryLevel: Int = 0
    @Published var batteryState: String = "Neznámý"
    @Published var freeStorageGB: Double = 0
    @Published var totalStorageGB: Double = 0
    @Published var appMemoryMB: Double = 0
    @Published var totalDeviceRAMGB: Double = 0
    @Published var thermalStateName: String = "Normální 🟢"
    @Published var thermalColor: Color = .green
    @Published var systemUptime: String = "00h 00m 00s"
    @Published var actionMessage: String?

    let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        as? String ?? "1.0.0"

    let buildNumber =
        Bundle.main.infoDictionary?["CFBundleVersion"]
        as? String ?? "1"

    let bundleID =
        Bundle.main.bundleIdentifier ?? "com.local.app"

    let deviceModel = UIDevice.current.model
    let systemVersion = UIDevice.current.systemVersion
    let deviceName = UIDevice.current.name

    private var timer: Timer?

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        fetchRealDeviceMetrics()
        startTelemetryLoop()
    }

    func fetchRealDeviceMetrics() {

        // MARK: Battery
        let rawLevel = UIDevice.current.batteryLevel

        batteryLevel =
            rawLevel >= 0
            ? Int(rawLevel * 100)
            : 0

        switch UIDevice.current.batteryState {
        case .charging:
            batteryState = "Nabíjí se ⚡"
        case .full:
            batteryState = "Plně nabito 🔌"
        case .unplugged:
            batteryState = "Na baterii 🔋"
        default:
            batteryState = "Neznámý ❓"
        }

        // MARK: Storage
        let homeURL = URL(
            fileURLWithPath: NSHomeDirectory()
        )

        if let values = try? homeURL.resourceValues(
            forKeys: [
                .volumeAvailableCapacityKey,
                .volumeTotalCapacityKey
            ]
        ) {
            if let free = values.volumeAvailableCapacity,
               let total = values.volumeTotalCapacity {

                freeStorageGB =
                    Double(free) / 1_073_741_824

                totalStorageGB =
                    Double(total) / 1_073_741_824
            }
        }

        // MARK: RAM
        var info = mach_task_basic_info()

        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size
        ) / 4

        let result: kern_return_t =
            withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(
                    to: integer_t.self,
                    capacity: Int(count)
                ) { ptr in
                    task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        ptr,
                        &count
                    )
                }
            }

        if result == KERN_SUCCESS {
            appMemoryMB =
                Double(info.resident_size)
                / 1024
                / 1024
        }

        totalDeviceRAMGB =
            Double(ProcessInfo.processInfo.physicalMemory)
            / 1_073_741_824

        // MARK: Thermal State
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            thermalStateName = "Normální 🟢"
            thermalColor = .green

        case .fair:
            thermalStateName = "Mírně teplé 🟡"
            thermalColor = .yellow

        case .serious:
            thermalStateName = "Horké 🟠"
            thermalColor = .orange

        case .critical:
            thermalStateName = "Kritické 🔴"
            thermalColor = .red

        @unknown default:
            thermalStateName = "Neznámé ⚪"
            thermalColor = .gray
        }

        // MARK: Uptime
        let uptime = ProcessInfo.processInfo.systemUptime
        let totalSeconds = Int(uptime)

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        systemUptime = String(
            format: "%02dh %02dm %02ds",
            hours,
            minutes,
            seconds
        )
    }

    private func startTelemetryLoop() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.fetchRealDeviceMetrics()
            }
        }
    }

    func clearRealCache() {
        guard let cacheURL =
            FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first
        else {
            return
        }

        do {
            let files =
                try FileManager.default.contentsOfDirectory(
                    at: cacheURL,
                    includingPropertiesForKeys: nil
                )

            for file in files {
                try FileManager.default.removeItem(
                    at: file
                )
            }

            fetchRealDeviceMetrics()

            showAction(
                "Cache byla vymazána! 🧹💾"
            )

        } catch {
            showAction(
                "Chyba při mazání cache: \(error.localizedDescription)"
            )
        }
    }

    func triggerHapticFeedback() {
        let generator =
            UIImpactFeedbackGenerator(
                style: .heavy
            )

        generator.prepare()
        generator.impactOccurred()

        showAction(
            "Haptika aktivována! 📳✨"
        )
    }

    private func showAction(_ text: String) {
        withAnimation(.spring()) {
            actionMessage = text
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3
        ) {
            withAnimation(.spring()) {
                self.actionMessage = nil
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Content View 📱

struct ContentView: View {

    @StateObject private var adminManager =
        RealSystemAdminManager()

    var body: some View {

        TabView {

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    "Domů",
                    systemImage: "house.fill"
                )
            }

            NavigationStack {
                CreditsView()
            }
            .tabItem {
                Label(
                    "Kredity",
                    systemImage:
                        "heart.text.square.fill"
                )
            }
        }
        .environmentObject(adminManager)
    }
}

// MARK: - Home View 🫧

struct HomeView: View {

    @EnvironmentObject
    private var adminManager: RealSystemAdminManager

    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var isLoading = false
    @State private var selectedTint = 0

    private var selectedColor: Color {
        switch selectedTint {
        case 0: return .blue
        case 1: return .purple
        case 2: return .pink
        case 3: return .orange
        default: return .green
        }
    }

    var body: some View {

        ScrollView {

            GlassEffectContainer(spacing: 18) {

                VStack(spacing: 18) {

                    // MARK: Hero
                    VStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 86, height: 86)
                            .glassEffect(.regular.tint(selectedColor.opacity(0.45)), in: .circle)

                        Text("Liquid Glass")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Full interactive playground")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)

                    // MARK: Device Status
                    HStack(spacing: 12) {
                        Circle()
                            .fill(adminManager.thermalColor)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stav zařízení")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(adminManager.thermalStateName)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        Image(systemName: "battery.75percent")

                        Text("\(adminManager.batteryLevel)%")
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .glassEffect(.regular.tint(adminManager.thermalColor.opacity(0.16)), in: .capsule)

                    // MARK: Toggle
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("Glass Toggle", systemImage: "switch.2")
                                .font(.headline)

                            Spacer()

                            Text(isToggleOn ? "ON" : "OFF")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .glassEffect(isToggleOn ? .regular.tint(.green.opacity(0.3)) : .regular, in: .capsule)
                        }

                        Toggle("Interaktivní přepínač", isOn: $isToggleOn)
                            .tint(.blue)
                    }
                    .padding(20)
                    .glassEffect(isToggleOn ? .regular.tint(.blue.opacity(0.18)) : .regular, in: .rect(cornerRadius: 28))

                    // MARK: Slider
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("Glass Slider", systemImage: "slider.horizontal.3")
                                .font(.headline)

                            Spacer()

                            Text("\(Int(sliderValue))")
                                .font(.headline)
                                .monospacedDigit()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .glassEffect(.regular.tint(.purple.opacity(0.25)), in: .capsule)
                        }

                        Slider(value: $sliderValue, in: 0...100)
                            .tint(.purple)

                        HStack {
                            Text("0")
                            Spacer()
                            Text("50")
                            Spacer()
                            Text("100")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .glassEffect(.regular.tint(.purple.opacity(0.14)), in: .rect(cornerRadius: 28))

                    // MARK: Tint Playground
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Glass Tint", systemImage: "paintpalette.fill")
                            .font(.headline)

                        HStack(spacing: 12) {
                            tintButton(color: .blue, index: 0)
                            tintButton(color: .purple, index: 1)
                            tintButton(color: .pink, index: 2)
                            tintButton(color: .orange, index: 3)
                            tintButton(color: .green, index: 4)
                        }
                    }
                    .padding(20)
                    .glassEffect(.regular.tint(selectedColor.opacity(0.14)), in: .rect(cornerRadius: 28))

                    // MARK: Loading
                    VStack(spacing: 14) {
                        Image(systemName: isLoading ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(isLoading ? .orange : .green)

                        Text(isLoading ? "Probíhá operace…" : "Připraveno")
                            .font(.headline)

                        Text(isLoading ? "Liquid Glass playground pracuje." : "Všechny systémy jsou připravené.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        if isLoading {
                            ProgressView()
                                .controlSize(.large)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .glassEffect(isLoading ? .regular.tint(.orange.opacity(0.18)) : .regular.tint(.green.opacity(0.12)), in: .rect(cornerRadius: 30))

                    // MARK: Main Liquid Glass Button
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isLoading.toggle()
                        }
                    } label: {
                        Label(isLoading ? "Zastavit" : "Spustit", systemImage: isLoading ? "stop.fill" : "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(isLoading ? .red : .blue)
                    .controlSize(.large)

                    // MARK: Quick Actions
                    HStack(spacing: 12) {
                        glassAction(icon: "waveform") {
                            adminManager.triggerHapticFeedback()
                        }

                        glassAction(icon: "arrow.clockwise") {
                            adminManager.fetchRealDeviceMetrics()
                        }

                        NavigationLink {
                            AdminPanelView()
                        } label: {
                            Image(systemName: "shield.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 56, height: 56)

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 56, height: 56)
                    }

                    // MARK: Metrics
                    HStack(spacing: 12) {
                        miniMetric(
                            title: "RAM",
                            value: String(format: "%.1f GB", adminManager.totalDeviceRAMGB),
                            icon: "memorychip",
                            color: .purple
                        )

                        miniMetric(
                            title: "Volné místo",
                            value: String(format: "%.1f GB", adminManager.freeStorageGB),
                            icon: "internaldrive",
                            color: .blue
                        )
                    }

                    // MARK: Action Message
                    if let message = adminManager.actionMessage {
                        Text(message)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .glassEffect(.regular.tint(.green.opacity(0.2)), in: .capsule)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .background {
            LinearGradient(
                colors: [
                    .blue.opacity(0.12),
                    .purple.opacity(0.10),
                    .pink.opacity(0.06),
                    .clear
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
                HStack(spacing: 8) {
                    NavigationLink {
                        AdminPanelView()
                    } label: {
                        Image(systemName: "shield.fill")
                    }
                    .buttonStyle(.glass)

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }

    // MARK: Tint Button
    @ViewBuilder
    private func tintButton(color: Color, index: Int) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedTint = index
            }
        } label: {
            Circle()
                .fill(color.gradient)
                .frame(width: 40, height: 40)
                .overlay {
                    if selectedTint == index {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
        }
        .buttonStyle(.glass)
    }

    // MARK: Glass Action
    @ViewBuilder
    private func glassAction(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
        }
        .buttonStyle(.glass)
        .frame(width: 56, height: 56)
    }

    // MARK: Mini Metric
    @ViewBuilder
    private func miniMetric(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline)
                    .monospacedDigit()
            }

            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular.tint(color.opacity(0.14)), in: .rect(cornerRadius: 24))
    }
}

// MARK: - Admin Panel 🛡️

struct AdminPanelView: View {

    @EnvironmentObject
    private var adminManager: RealSystemAdminManager

    var body: some View {

        List {

            if let message = adminManager.actionMessage {
                Section {
                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                }
            }

            Section("Reálný Stav Zařízení 📊") {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        MetricCard(
                            title: "Baterie",
                            value: "\(adminManager.batteryLevel)%",
                            icon: "battery.100",
                            color: adminManager.batteryLevel > 20 ? .green : .red
                        )

                        MetricCard(
                            title: "Volné Místo",
                            value: String(format: "%.1f GB", adminManager.freeStorageGB),
                            icon: "internaldrive",
                            color: .blue
                        )
                    }

                    GridRow {
                        MetricCard(
                            title: "RAM Aplikace",
                            value: String(format: "%.1f MB", adminManager.appMemoryMB),
                            icon: "memorychip",
                            color: .purple
                        )

                        MetricCard(
                            title: "Teplota HW",
                            value: adminManager.thermalStateName,
                            icon: "thermometer.medium",
                            color: adminManager.thermalColor
                        )
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Systémové Informace ℹ️") {
                infoRow("Název Zařízení", "iphone", adminManager.deviceName)
                infoRow("Verze iOS", "apple.logo", "iOS \(adminManager.systemVersion)")
                infoRow("Stav Baterie", "bolt.fill", adminManager.batteryState)
                infoRow("Uptime Telefonu", "clock.fill", adminManager.systemUptime)
                infoRow("Celková RAM HW", "cpu", String(format: "%.1f GB RAM", adminManager.totalDeviceRAMGB))
                infoRow("Celková Kapacita", "sdcard", String(format: "%.1f GB", adminManager.totalStorageGB))
            }

            Section("Metadata Buildu 📦") {
                infoRow("Bundle ID", "shippingbox", adminManager.bundleID)
                infoRow("Verze Aplikace", "tag.fill", "\(adminManager.appVersion) (\(adminManager.buildNumber))")
            }

            Section("Nativní Akce 🛠️") {
                Button {
                    adminManager.clearRealCache()
                } label: {
                    Label("Smazat Reálnou Cache", systemImage: "trash.fill")
                }
                .foregroundStyle(.red)

                Button {
                    adminManager.triggerHapticFeedback()
                } label: {
                    Label("Test Haptiky", systemImage: "waveform")
                }

                Button {
                    adminManager.fetchRealDeviceMetrics()
                } label: {
                    Label("Obnovit Telemetrii", systemImage: "arrow.clockwise")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Admin Panel")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private func infoRow(_ title: String, _ icon: String, _ value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Metric Card 📊

struct MetricCard: View {

    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(color.opacity(0.14)), in: .rect(cornerRadius: 22))
    }
}

// MARK: - Settings ⚙️

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear")
                .font(.system(size: 48, weight: .medium))
                .frame(width: 88, height: 88)
                .glassEffect(.regular.tint(.gray.opacity(0.2)), in: .circle)

            Text("Nastavení")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Nastavení aplikace ⚙️✨")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Credits 💖

struct CreditsView: View {
    var body: some View {
        ScrollView {
            GlassEffectContainer(spacing: 18) {
                VStack(spacing: 18) {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundStyle(.pink)

                        Text("iOsApp")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .glassEffect(.regular.tint(.pink.opacity(0.18)), in: .rect(cornerRadius: 30))

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Tým")
                            .font(.headline)

                        creditRow("Vývojář", "iOSondyhop ", "hammer.fill")
                        creditRow("UI/UX Design", "Shadow_ROBLOX", "paintpalette")
                    }
                    .padding(20)
                    .glassEffect(.regular.tint(.blue.opacity(0.12)), in: .rect(cornerRadius: 28))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Open-Source")
                            .font(.headline)

                        Link("GitHub", destination: URL(string: "https://github.com")!)
                            .buttonStyle(.glass)

                        Link("SF Symbols", destination: URL(string: "https://developer.apple.com/sf-symbols/")!)
                            .buttonStyle(.glass)
                    }
                    .padding(20)
                    .glassEffect(.regular.tint(.purple.opacity(0.12)), in: .rect(cornerRadius: 28))

                    Text("© 2026 Všechna práva vyhrazena")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .glassEffect(.regular, in: .capsule)
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .background {
            LinearGradient(
                colors: [
                    .pink.opacity(0.08),
                    .purple.opacity(0.08),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Kredity")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func creditRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)

            Text(title)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
