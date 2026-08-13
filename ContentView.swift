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
                    Label("Vývojář", systemImage: "code.line.horizontal.base")
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
            Section(header: Text("Kde nás najdete 🔗")) {
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
                    Text("© 2026 Všechna práva vyhrazena 🎉")
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


// MARK: - Home View
struct HomeView: View {
    @State private var isToggleOn = false
    @State private var sliderValue = 50.0
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // Switch / Toggle 🎚️
                Toggle(isOn: $isToggleOn) {
                    Text("Přepínač (Switch)")
                        .font(.headline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Slider 🎛️
                VStack(alignment: .leading) {
                    Text("Slider hodnota: \(Int(sliderValue))")
                        .font(.headline)
                    Slider(value: $sliderValue, in: 0...100)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Loading Spinner 🌀
                VStack(spacing: 10) {
                    Text("Loading Spinner")
                        .font(.headline)
                    
                    if isLoading {
                        ProgressView()
                            .controlSize(.large)
                    } else {
                        Text("Stiskni tlačítko níže pro načítání")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Button 👆
                Button(action: {
                    withAnimation {
                        isLoading.toggle()
                    }
                }) {
                    Text(isLoading ? "Zastavit Spinner 🛑" : "Spustit Spinner 🚀")
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
        .toolbar {
            // Tlačítko vpravo nahoře s ikonou Settings ⚙️
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
        }
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

            Text("Tohle je stránka nastavení aplikace!")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Nastavení")
        .navigationBarTitleDisplayMode(.inline)
    }
}
