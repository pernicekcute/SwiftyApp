import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Domů 🏠", systemImage: "house.fill")
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
        ZStack {
            // Barevný podklad pro vyniknutí Liquid Glass efektu u tlačítek 🌈
            LinearGradient(
                colors: [.indigo, .purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    
                    // Switch / Toggle 🔘
                    Toggle(isOn: $isToggleOn) {
                        Text("Přepínač (Switch) 🔘")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()

                    // Slider 🎛️
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Slider hodnota: \(Int(sliderValue)) 📊")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Slider(value: $sliderValue, in: 0...100)
                            .tint(.white)
                    }
                    .padding()

                    // Loading Spinner 🌀
                    VStack(spacing: 12) {
                        Text("Loading Spinner ⏳")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isLoading {
                            ProgressView()
                                .controlSize(.large)
                                .tint(.white)
                        } else {
                            Text("Stiskni tlačítko níže 👇")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()

                    // 🧊 LIQUID GLASS BUTTON 1 👆
                    Button(action: {
                        withAnimation(.spring()) {
                            isLoading.toggle()
                        }
                    }) {
                        Text(isLoading ? "Zastavit Spinner 🛑" : "Spustit Spinner 🚀")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .liquidGlassButtonStyle()

                }
                .padding()
            }
        }
        .navigationTitle("Domů 🏠")
        .toolbar {
            // 🧊 LIQUID GLASS BUTTON 2 (Settings ikona vpravo nahoře) ⚙️
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
        }
    }
}

// MARK: - Liquid Glass Style Modifier pro Tlačítka 🧊
extension View {
    func liquidGlassButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Settings View ⚙️
struct SettingsView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)

                Text("Nastavení ⚙️")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text("Stránka nastavení ✨")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Nastavení ⚙️")
        .navigationBarTitleDisplayMode(.inline)
    }
}
