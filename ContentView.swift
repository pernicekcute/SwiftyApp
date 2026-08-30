import SwiftUI

struct ContentView: View {
    // 📌 Drží informaci o tom, zda je spodní panel zobrazený
    @State private var showSheet = true

    var body: some View {
        // 🎨 Jednoduché pozadí místo mapy
        Color(.systemGray5)
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                // 📱 Náš vlastní spodní panel
                BottomSheetView()
                    // 📏 Definuje, jak moc se dá panel roztáhnout (malý, střední, velký)
                    .presentationDetents([.fraction(0.15), .medium, .large])
                    // 👆 Umožňuje interakci s pozadím, i když je panel zobrazený
                    .presentationBackgroundInteraction(.enabled)
                    // 🚫 Zabrání tomu, aby uživatel panel úplně zavřel
                    .interactiveDismissDisabled()
            }
    }
}

struct BottomSheetView: View {
    @State private var sliderValue: Double = 50
    @State private var toggleValue: Bool = false
    @State private var textValue: String = ""
    
    // 👤 Zobrazení profilu (Apple ID)
    @State private var showProfile = false

    var body: some View {
        VStack(spacing: 25) {
            
            // 🔝 Horní lišta s posuvníkem a profilovkou
            HStack(spacing: 15) {
                // 🎚️ Místo vyhledávací lišty je tady Slider!
                Slider(value: $sliderValue, in: 0...100)
                    .tint(.blue)
                
                // 🖼️ Profilovka
                Button(action: {
                    showProfile.toggle()
                }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.orange)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // ⬇️ Obsah, který je vidět po rozbalení panelu
            VStack(spacing: 20) {
                
                // 🔘 Tlačítko
                Button(action: {
                    print("Tlačítko bylo stisknuto! 🎉")
                }) {
                    Text("Klikni na mě! 🚀")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                // 🟢 Přepínač
                Toggle("Zapnout super funkci ✨", isOn: $toggleValue)
                    .font(.body)

                // ✍️ Textové pole
                TextField("Napiš něco sem...", text: $textValue)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer() // 🌌 Vyplní zbytek místa dole
        }
        // 📄 Zobrazení Apple ID profilu jako dalšího sheetu
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .presentationDetents([.medium])
        }
    }
}

// 👤 Zobrazení profilu
struct ProfileView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 90, height: 90)
                .foregroundColor(.orange)
                .padding(.top, 30)

            // 📛 Jméno
            Text("Will Smith")
                .font(.title2)
                .fontWeight(.bold)

            // 📧 Apple ID
            Text("will.smith@icloud.com")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
