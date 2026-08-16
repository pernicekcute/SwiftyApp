import SwiftUI

struct ContentView: View {
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
    }
}

// MARK: - Home View 🏠
struct HomeView: View {
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
            // Tlačítka vpravo nahoře pro Admin Panel a Nastavení 🔝⚙️🛡️
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(destination: AdminPanelView()) {
                    Image(systemName: "shield.gearshape.fill")
                        .font(.title3)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title3)
                }
            }
        }
    }
}

// MARK: - Admin Panel View 🛡️👑
struct AdminPanelView: View {
    @State private var maintenanceMode = false
    @State private var debugLogs = true
    @State private var apiRateLimit = 250.0
    @State private var selectedServer = "EU-Central"

    var body: some View {
        List {
            // MARK: - Systémový přehled & Metriky 📊
            Section(header: Text("Systémový Přehled 📈")) {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        MetricCard(title: "Uživatelé", value: "1,248", icon: "person.3.fill", color: .blue)
                        MetricCard(title: "Uptime", value: "99.9%", icon: "server.rack", color: .green)
                    }
                    GridRow {
                        MetricCard(title: "Zátěž CPU", value: "32%", icon: "cpu", color: .orange)
                        MetricCard(title: "Chyby 24h", value: "0", icon: "exclamationmark.triangle.fill", color: .red)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            // MARK: - Správa Serveru & Údržba 🎛️
            Section(header: Text("Správa Systému & Serverů 🎛️")) {
                Toggle(isOn: $maintenanceMode) {
                    Label("Režim údržby 🛠️", systemImage: "wrench.and.screwdriver.fill")
                }
                
                Toggle(isOn: $debugLogs) {
                    Label("Podrobné Logování 📜", systemImage: "terminal.fill")
                }

                Picker("Aktivní Server 🌐", selection: $selectedServer) {
                    Text("EU-Central (Praha) 🇨🇿").tag("EU-Central")
                    Text("US-East (N. Virginia) 🇺🇸").tag("US-East")
                    Text("AP-East (Tokyo) 🇯🇵").tag("AP-East")
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("API Rate Limit ⚡", systemImage: "speedometer")
                        Spacer()
                        Text("\(Int(apiRateLimit)) req/min")
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $apiRateLimit, in: 50...1000, step: 50)
                }
                .padding(.vertical, 4)
            }

            // MARK: - Rychlé Admin Akce ⚡
            Section(header: Text("Rychlé Akce 🚀")) {
                Button(action: {}) {
                    Label("Obnovit Databázovou Cache 🔄", systemImage: "arrow.clockwise.circle.fill")
                }
                
                Button(action: {}) {
                    Label("Stáhnout Systémový Log 📥", systemImage: "doc.plaintext.fill")
                }

                Button(role: .destructive, action: {}) {
                    Label("Restartovat Aplikaci ⚠️", systemImage: "power")
                }
            }

            // MARK: - Audit Log 📝
            Section(header: Text("Poslední Aktivita 📜")) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("Záloha databáze dokončena 💾")
                            .font(.subheadline)
                        Text("Dnes, 08:15").font(.caption).foregroundColor(.gray)
                    }
                }
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Nový Admin přidán: Shadow_ROBLOX 👨‍💻")
                            .font(.subheadline)
                        Text("Včera, 22:40").font(.caption).foregroundColor(.gray)
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
