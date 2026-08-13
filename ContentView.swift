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
                    Text("Přepínač (Switch) 🔘")
                        .font(.headline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Slider 🎛️
                VStack(alignment: .leading) {
                    Text("Slider hodnota: \(Int(sliderValue)) 📊")
                        .font(.headline)
                    Slider(value: $sliderValue, in: 0...100)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Loading Spinner 🌀
                VStack(spacing: 10) {
                    Text("Loading Spinner ⏳")
                        .font(.headline)
                    
                    if isLoading {
                        ProgressView()
                            .controlSize(.large)
                    } else {
                        Text("Stiskni tlačítko níže pro načítání 👇")
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
        .navigationTitle("Domů 🏠")
        .toolbar {
            // Tlačítko vpravo nahoře s ikonou Settings ⚙️
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
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

            Text("Nastavení ⚙️")
                .font(.largeTitle)
                .bold()

            Text("Tohle je stránka nastavení aplikace! 🛠️✨")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Nastavení ⚙️")
        .navigationBarTitleDisplayMode(.inline)
    }
}
