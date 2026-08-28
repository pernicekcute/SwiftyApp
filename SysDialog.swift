import SwiftUI

struct ContentView: View {
    // 🎛️ Konfigurovatelné parametry
    @State private var alertTitle = "SwiftyApp"
    @State private var alertMessage = "Start iOS Destruction?"
    
    @State private var button1Text = "Yes"
    @State private var button2Text = "No"
    @State private var showButton2 = true // Toggle pro skrytí/zobrazení druhého tlačítka
    
    // Stavové proměnné pro běh aplikace
    @State private var showingAlert = true
    @State private var startDestruction = false

    var body: some View {
        ZStack {
            // Černé pozadí přes celou obrazovku ⬛️
            Color.black
                .ignoresSafeArea() 
            
            // Zobrazí spinner a text až po kliknutí na "Yes" ✨
            if startDestruction {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Restarting iOS...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            } else {
                // Jen informační text na pozadí, když zrovna svítí alert 📱
                VStack(spacing: 12) {
                    Text("⚙️ Nastavení alertu")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("Znovu zobrazit alert") {
                        showingAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        // Nativní alert okno s dynamickými parametry 🚨
        .alert(alertTitle, isPresented: $showingAlert) {
            // Tlačítko 1 (vždy viditelné)
            Button(button1Text) {
                startDestruction = true
            }
            
            // Tlačítko 2 (zobrazí se nebo schová podle přepínače) 🎛️
            if showButton2 {
                Button(button2Text, role: .cancel) {
                    exit(0)
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static varg previews: some View {
        ContentView()
    }
}
