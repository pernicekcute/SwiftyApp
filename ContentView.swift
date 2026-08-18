import SwiftUI
import Combine
import UIKit
import Darwin
import MachO

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

    // MARK: - Telemetrie

    func fetchRealDeviceMetrics() {

        // Battery
        let rawLevel = UIDevice.current.batteryLevel

        batteryLevel =
            rawLevel >= 0
            ? Int(rawLevel * 100)
            : 100

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

        // Storage
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())

        if let values = try? homeURL.resourceValues(
            forKeys: [
                .volumeAvailableCapacityKey,
                .volumeTotalCapacityKey
            ]
        ) {

            if let free = values.volumeAvailableCapacity,
               let total = values.volumeTotalCapacity {

                freeStorageGB =
                    Double(free) / 1_073_741_824.0

                totalStorageGB =
                    Double(total) / 1_073_741_824.0
            }
        }

        // App RAM
        var stats = mach_task_basic_info()

        var count =
            mach_msg_type_number_t(
                MemoryLayout<mach_task_basic_info>.size
            ) / 4

        let kerr: kern_return_t =
            withUnsafeMutablePointer(to: &stats) {
                $0.withMemoryRebound(
                    to: integer_t.self,
                    capacity: Int(count)
                ) {

                    task_info(
                        mach_task_self_,
                        task_flavor_t(MACH_TASK_BASIC_INFO),
                        $0,
                        &count
                    )
                }
            }

        if kerr == KERN_SUCCESS {
            appMemoryMB =
                Double(stats.resident_size)
                / 1024.0
                / 1024.0
        }

        // Total RAM
        totalDeviceRAMGB =
            Double(ProcessInfo.processInfo.physicalMemory)
            / 1_073_741_824.0

        // Thermal state
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

        // Uptime
        let uptime =
            ProcessInfo.processInfo.systemUptime

        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60

        systemUptime =
            String(
                format: "%02dh %02dm %02ds",
                hours,
                minutes,
                seconds
            )
    }

    private func startTelemetryLoop() {

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in

            DispatchQueue.main.async {
                self?.fetchRealDeviceMetrics()
            }
        }
    }

    // MARK: - Cache

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
                try FileManager.default.removeItem(at: file)
            }

            fetchRealDeviceMetrics()

            showAction(
                "Složka Cache byla smazána z disku! 🧹💾"
            )

        } catch {

            showAction(
                "Chyba při mazání cache: \(error.localizedDescription) ⚠️"
            )
        }
    }

    // MARK: - Haptika

    func triggerHapticFeedback() {

        let generator =
            UIImpactFeedbackGenerator(style: .heavy)

        generator.prepare()
        generator.impactOccurred()

        showAction(
            "Haptický motor aktivován! 📳✨"
        )
    }

    private func showAction(_ text: String) {

        withAnimation(.spring(response: 0.4)) {
            actionMessage = text
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3
        ) {

            withAnimation(.spring(response: 0.4)) {
                self.actionMessage = nil
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}


// MARK: - Hlavní Container 📱

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
                    systemImage: "heart.text.square.fill"
                )
            }
        }
        .environmentObject(adminManager)
    }
}


// MARK: - Home View 🫧✨

struct HomeView: View {

    @EnvironmentObject var adminManager:
        RealSystemAdminManager

    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var isLoading = false
    @State private var selectedColor = 0

    var body: some View {

        ScrollView {

            GlassEffectContainer(spacing: 20) {

                VStack(spacing: 20) {

                    // MARK: Hero

                    VStack(spacing: 16) {

                        Image(systemName: "sparkles")
                            .font(
                                .system(
                                    size: 42,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                width: 88,
                                height: 88
                            )
                            .glassEffect(
                                .regular
                                    .tint(
                                        .blue.opacity(0.35)
                                    )
                                    .interactive(),
                                in: .circle
                            )

                        VStack(spacing: 5) {

                            Text("Liquid Glass")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("Full playground")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)


                    // MARK: Status

                    HStack(spacing: 12) {

                        Circle()
                            .fill(
                                adminManager.thermalColor
                            )
                            .frame(
                                width: 11,
                                height: 11
                            )
                            .shadow(
                                color:
                                    adminManager.thermalColor
                                    .opacity(0.7),
                                radius: 6
                            )

                        VStack(
                            alignment: .leading,
                            spacing: 2
                        ) {

                            Text("Stav zařízení")
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )

                            Text(
                                adminManager
                                    .thermalStateName
                            )
                            .fontWeight(.semibold)
                        }

                        Spacer()

                        Image(
                            systemName:
                                adminManager.batteryLevel > 20
                                ? "battery.75percent"
                                : "battery.25percent"
                        )

                        Text(
                            "\(adminManager.batteryLevel)%"
                        )
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .glassEffect(
                        .regular
                            .tint(
                                adminManager
                                    .thermalColor
                                    .opacity(0.12)
                            )
                            .interactive(),
                        in: .capsule
                    )


                    // MARK: Toggle

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        HStack {

                            Label(
                                "Glass Toggle",
                                systemImage: "switch.2"
                            )
                            .font(.headline)

                            Spacer()

                            Text(
                                isToggleOn
                                ? "ON"
                                : "OFF"
                            )
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(
                                .horizontal,
                                10
                            )
                            .padding(
                                .vertical,
                                5
                            )
                            .glassEffect(
                                .regular
                                    .tint(
                                        isToggleOn
                                        ? .green.opacity(0.35)
                                        : .gray.opacity(0.15)
                                    )
                                    .interactive(),
                                in: .capsule
                            )
                        }

                        Toggle(
                            isOn: $isToggleOn
                        ) {

                            Text(
                                isToggleOn
                                ? "Funkce aktivní"
                                : "Funkce neaktivní"
                            )
                        }
                        .tint(.blue)
                    }
                    .padding(20)
                    .glassEffect(
                        .regular
                            .tint(
                                isToggleOn
                                ? .blue.opacity(0.2)
                                : nil
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 30
                        )
                    )


                    // MARK: Slider

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        HStack {

                            Label(
                                "Glass Slider",
                                systemImage:
                                    "slider.horizontal.3"
                            )
                            .font(.headline)

                            Spacer()

                            Text(
                                "\(Int(sliderValue))"
                            )
                            .font(
                                .system(
                                    .title3,
                                    design: .rounded
                                )
                            )
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .padding(
                                .horizontal,
                                13
                            )
                            .padding(
                                .vertical,
                                7
                            )
                            .glassEffect(
                                .regular
                                    .tint(
                                        .purple.opacity(0.25)
                                    )
                                    .interactive(),
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

                            Text("50")

                            Spacer()

                            Text("100")
                        }
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    .padding(20)
                    .glassEffect(
                        .regular
                            .tint(
                                .purple.opacity(0.14)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 30
                        )
                    )


                    // MARK: Color Playground

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {

                        Label(
                            "Glass Tint",
                            systemImage:
                                "paintpalette.fill"
                        )
                        .font(.headline)

                        HStack(spacing: 12) {

                            GlassColorButton(
                                color: .blue,
                                selected:
                                    selectedColor == 0
                            ) {
                                selectedColor = 0
                            }

                            GlassColorButton(
                                color: .purple,
                                selected:
                                    selectedColor == 1
                            ) {
                                selectedColor = 1
                            }

                            GlassColorButton(
                                color: .pink,
                                selected:
                                    selectedColor == 2
                            ) {
                                selectedColor = 2
                            }

                            GlassColorButton(
                                color: .orange,
                                selected:
                                    selectedColor == 3
                            ) {
                                selectedColor = 3
                            }

                            GlassColorButton(
                                color: .green,
                                selected:
                                    selectedColor == 4
                            ) {
                                selectedColor = 4
                            }
                        }
                    }
                    .padding(20)
                    .glassEffect(
                        .regular
                            .tint(
                                selectedColor == 0
                                ? .blue.opacity(0.18)
                                : selectedColor == 1
                                ? .purple.opacity(0.18)
                                : selectedColor == 2
                                ? .pink.opacity(0.18)
                                : selectedColor == 3
                                ? .orange.opacity(0.18)
                                : .green.opacity(0.18)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 30
                        )
                    )


                    // MARK: Loading

                    VStack(spacing: 15) {

                        Image(
                            systemName:
                                isLoading
                                ? "arrow.triangle.2.circlepath"
                                : "checkmark.circle.fill"
                        )
                        .font(
                            .system(
                                size: 36,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            isLoading
                            ? .orange
                            : .green
                        )
                        .symbolEffect(
                            .rotate,
                            isActive: isLoading
                        )

                        Text(
                            isLoading
                            ? "Probíhá operace…"
                            : "Připraveno"
                        )
                        .font(.headline)

                        Text(
                            isLoading
                            ? "Liquid Glass playground právě pracuje."
                            : "Všechny systémy jsou připravené."
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                        .multilineTextAlignment(
                            .center
                        )

                        if isLoading {

                            ProgressView()
                                .controlSize(.large)
                                .tint(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .glassEffect(
                        .regular
                            .tint(
                                isLoading
                                ? .orange.opacity(0.18)
                                : .green.opacity(0.12)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 30
                        )
                    )


                    // MARK: Main Glass Button

                    Button {

                        withAnimation(
                            .spring(
                                response: 0.35,
                                dampingFraction: 0.75
                            )
                        ) {
                            isLoading.toggle()
                        }

                    } label: {

                        Label(
                            isLoading
                            ? "Zastavit"
                            : "Spustit",
                            systemImage:
                                isLoading
                                ? "stop.fill"
                                : "play.fill"
                        )
                        .font(.headline)
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(
                        .glassProminent
                    )
                    .tint(
                        isLoading
                        ? .red
                        : .blue
                    )
                    .controlSize(.large)


                    // MARK: Quick Actions

                    HStack(spacing: 14) {

                        GlassActionButton(
                            icon: "waveform"
                        ) {
                            adminManager
                                .triggerHapticFeedback()
                        }

                        GlassActionButton(
                            icon: "arrow.clockwise"
                        ) {
                            adminManager
                                .fetchRealDeviceMetrics()
                        }

                        NavigationLink {
                            AdminPanelView()
                        } label: {

                            Image(
                                systemName:
                                    "shield.fill"
                            )
                            .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(
                            width: 58,
                            height: 58
                        )

                        NavigationLink {
                            SettingsView()
                        } label: {

                            Image(
                                systemName:
                                    "gear"
                            )
                            .font(.title3)
                        }
                        .buttonStyle(.glass)
                        .frame(
                            width: 58,
                            height: 58
                        )
                    }


                    // MARK: Device Info Cards

                    HStack(spacing: 14) {

                        MiniGlassMetric(
                            title: "RAM",
                            value: String(
                                format: "%.1f GB",
                                adminManager
                                    .totalDeviceRAMGB
                            ),
                            icon: "memorychip",
                            tint: .purple
                        )

                        MiniGlassMetric(
                            title: "Volné",
                            value: String(
                                format: "%.1f GB",
                                adminManager
                                    .freeStorageGB
                            ),
                            icon: "internaldrive",
                            tint: .blue
                        )
                    }


                    // MARK: Action Message

                    if let message =
                        adminManager.actionMessage {

                        Text(message)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(
                                .center
                            )
                            .padding(
                                .horizontal,
                                18
                            )
                            .padding(
                                .vertical,
                                12
                            )
                            .glassEffect(
                                .regular
                                    .tint(
                                        .green.opacity(0.2)
                                    )
                                    .interactive(),
                                in: .capsule
                            )
                            .transition(
                                .scale
                                .combined(
                                    with: .opacity
                                )
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 35)
            }
        }
        .scrollIndicators(.hidden)

        // Background remains intentionally simple.
        // The actual controls are Liquid Glass.
        .background {

            ZStack {

                LinearGradient(
                    colors: [
                        .blue.opacity(0.16),
                        .purple.opacity(0.12),
                        .pink.opacity(0.08),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        .blue.opacity(0.10)
                    )
                    .frame(
                        width: 280,
                        height: 280
                    )
                    .blur(radius: 70)
                    .offset(
                        x: -120,
                        y: -250
                    )

                Circle()
                    .fill(
                        .purple.opacity(0.10)
                    )
                    .frame(
                        width: 300,
                        height: 300
                    )
                    .blur(radius: 80)
                    .offset(
                        x: 140,
                        y: 180
                    )
            }
            .ignoresSafeArea()
        }

        .navigationTitle("Domů")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {

            ToolbarItem(
                placement: .topBarTrailing
            ) {

                HStack(spacing: 10) {

                    NavigationLink {
                        AdminPanelView()
                    } label: {

                        Image(
                            systemName:
                                "shield.fill"
                        )
                    }
                    .buttonStyle(.glass)

                    NavigationLink {
                        SettingsView()
                    } label: {

                        Image(
                            systemName:
                                "gear"
                        )
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}


// MARK: - Glass Color Button 🎨

struct GlassColorButton: View {

    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Circle()
                .fill(color.gradient)
                .frame(
                    width: 42,
                    height: 42
                )
                .overlay {

                    if selected {

                        Image(
                            systemName:
                                "checkmark"
                        )
                        .font(
                            .caption.bold()
                        )
                        .foregroundStyle(.white)
                    }
                }
        }
        .buttonStyle(.glass)
        .glassEffect(
            selected
            ? .regular
                .tint(
                    color.opacity(0.4)
                )
                .interactive()
            : .regular.interactive(),
            in: .circle
        )
    }
}


// MARK: - Glass Action Button ⚡

struct GlassActionButton: View {

    let icon: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.title3)
        }
        .buttonStyle(.glass)
        .frame(
            width: 58,
            height: 58
        )
    }
}


// MARK: - Mini Glass Metric 📊

struct MiniGlassMetric: View {

    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text(title)
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )

                Text(value)
                    .font(.headline)
                    .monospacedDigit()
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassEffect(
            .regular
                .tint(
                    tint.opacity(0.14)
                )
                .interactive(),
            in: .rect(
                cornerRadius: 24
            )
        )
    }
}


// MARK: - Admin Panel View 🛡️

struct AdminPanelView: View {

    @EnvironmentObject var adminManager:
        RealSystemAdminManager

    var body: some View {

        List {

            if let msg =
                adminManager.actionMessage {

                Section {

                    Text(msg)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.green)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                }
            }

            Section(
                header:
                    Text("Reálný Stav Zařízení 📊")
            ) {

                Grid(
                    horizontalSpacing: 12,
                    verticalSpacing: 12
                ) {

                    GridRow {

                        MetricCard(
                            title: "Baterie",
                            value:
                                "\(adminManager.batteryLevel)%",
                            icon:
                                "battery.100",
                            color:
                                adminManager.batteryLevel > 20
                                ? .green
                                : .red
                        )

                        MetricCard(
                            title: "Volné Místo",
                            value:
                                String(
                                    format: "%.1f GB",
                                    adminManager
                                        .freeStorageGB
                                ),
                            icon:
                                "internaldrive",
                            color: .blue
                        )
                    }

                    GridRow {

                        MetricCard(
                            title: "RAM Aplikace",
                            value:
                                String(
                                    format: "%.1f MB",
                                    adminManager
                                        .appMemoryMB
                                ),
                            icon:
                                "memorychip",
                            color: .purple
                        )

                        MetricCard(
                            title: "Teplota HW",
                            value:
                                adminManager
                                    .thermalStateName,
                            icon:
                                "thermometer.medium",
                            color:
                                adminManager
                                    .thermalColor
                        )
                    }
                }
                .listRowBackground(
                    Color.clear
                )
                .listRowInsets(
                    EdgeInsets()
                )
            }


            Section(
                header:
                    Text("Systémové Informace ℹ️")
            ) {

                AdminInfoRow(
                    title: "Název Zařízení",
                    icon: "iphone",
                    value:
                        adminManager.deviceName
                )

                AdminInfoRow(
                    title: "Verze iOS",
                    icon: "apple.logo",
                    value:
                        "iOS \(adminManager.systemVersion)"
                )

                AdminInfoRow(
                    title: "Stav Baterie",
                    icon: "bolt.fill",
                    value:
                        adminManager.batteryState
                )

                AdminInfoRow(
                    title: "Uptime Telefonu",
                    icon: "clock.fill",
                    value:
                        adminManager.systemUptime
                )

                AdminInfoRow(
                    title: "Celková RAM HW",
                    icon: "cpu",
                    value:
                        String(
                            format:
                                "%.1f GB RAM",
                            adminManager
                                .totalDeviceRAMGB
                        )
                )

                AdminInfoRow(
                    title: "Celková Kapacita",
                    icon: "sdcard",
                    value:
                        String(
                            format:
                                "%.1f GB",
                            adminManager
                                .totalStorageGB
                        )
                )
            }


            Section(
                header:
                    Text("Metadata Buildu 📦")
            ) {

                AdminInfoRow(
                    title: "Bundle ID",
                    icon: "shippingbox",
                    value:
                        adminManager.bundleID
                )

                AdminInfoRow(
                    title: "Verze Aplikace",
                    icon: "tag.fill",
                    value:
                        "\(adminManager.appVersion) (\(adminManager.buildNumber))"
                )
            }


            Section(
                header:
                    Text("Nativní Akce 🛠️")
            ) {

                Button {

                    adminManager.clearRealCache()

                } label: {

                    Label(
                        "Smazat Reálnou Cache",
                        systemImage:
                            "trash.fill"
                    )
                    .foregroundStyle(.red)
                }

                Button {

                    adminManager
                        .triggerHapticFeedback()

                } label: {

                    Label(
                        "Test Haptiky",
                        systemImage:
                            "waveform"
                    )
                }

                Button {

                    adminManager
                        .fetchRealDeviceMetrics()

                } label: {

                    Label(
                        "Obnovit Telemetrii",
                        systemImage:
                            "arrow.clockwise"
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Admin Panel 🛡️")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(
            .hidden,
            for: .tabBar
        )
    }
}


// MARK: - Admin Info Row

struct AdminInfoRow: View {

    let title: String
    let icon: String
    let value: String

    var body: some View {

        HStack {

            Label(
                title,
                systemImage: icon
            )

            Spacer()

            Text(value)
                .foregroundStyle(
                    .secondary
                )
        }
    }
}


// MARK: - Metric Card

struct MetricCard: View {

    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .glassEffect(
            .regular
                .tint(
                    color.opacity(0.14)
                )
                .interactive(),
            in: .rect(
                cornerRadius: 22
            )
        )
    }
}


// MARK: - Settings View ⚙️

struct SettingsView: View {

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: "gear")
                .font(
                    .system(
                        size: 50,
                        weight: .medium
                    )
                )
                .frame(
                    width: 90,
                    height: 90
                )
                .glassEffect(
                    .regular
                        .tint(
                            .gray.opacity(0.2)
                        )
                        .interactive(),
                    in: .circle
                )

            Text("Nastavení")
                .font(.largeTitle)
                .bold()

            Text(
                "Nastavení aplikace ⚙️✨"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(
            .hidden,
            for: .tabBar
        )
    }
}


// MARK: - Credits View 💖

struct CreditsView: View {

    var body: some View {

        ScrollView {

            GlassEffectContainer(spacing: 18) {

                VStack(spacing: 18) {

                    VStack(spacing: 14) {

                        Image(
                            systemName:
                                "heart.text.square.fill"
                        )
                        .font(
                            .system(
                                size: 48,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.pink)

                        Text("iOsApp")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(25)
                    .glassEffect(
                        .regular
                            .tint(
                                .pink.opacity(0.18)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 30
                        )
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        Text("Tým")
                            .font(.headline)

                        CreditRow(
                            title: "Vývojář",
                            value: "iOSondyhop ",
                            icon: "hammer.fill"
                        )

                        CreditRow(
                            title: "UI/UX Design",
                            value: "Shadow_ROBLOX",
                            icon: "paintpalette"
                        )
                    }
                    .padding(20)
                    .glassEffect(
                        .regular
                            .tint(
                                .blue.opacity(0.12)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 28
                        )
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        Text(
                            "Poděkování a open-source"
                        )
                        .font(.headline)

                        Link(
                            destination:
                                URL(
                                    string:
                                        "https://github.com"
                                )!
                        ) {

                            Label(
                                "Open-Source knihovny",
                                systemImage:
                                    "shippingbox.fill"
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }
                        .buttonStyle(.glass)

                        Link(
                            destination:
                                URL(
                                    string:
                                        "https://developer.apple.com/sf-symbols/"
                                )!
                        ) {

                            Label(
                                "SF Symbols",
                                systemImage:
                                    "star.fill"
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }
                        .buttonStyle(.glass)
                    }
                    .padding(20)
                    .glassEffect(
                        .regular
                            .tint(
                                .purple.opacity(0.12)
                            )
                            .interactive(),
                        in: .rect(
                            cornerRadius: 28
                        )
                    )


                    VStack(spacing: 12) {

                        Text(
                            "© 2026 Všechna práva vyhrazena"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text("Made with SwiftUI ")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .glassEffect(
                        .regular
                            .interactive(),
                        in: .capsule
                    )
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
}


// MARK: - Credit Row

struct CreditRow: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {

        HStack {

            Image(systemName: icon)
                .frame(
                    width: 28
                )

            Text(title)

            Spacer()

            Text(value)
                .foregroundStyle(
                    .secondary
                )
        }
    }
}