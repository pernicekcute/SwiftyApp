import SwiftUI

struct ContentView: View {
    // Stav pro zobrazení alertu (zapne se hned při startu) 🔔
    @State private var showingAlert = true
    // Stav pro přepnutí na načítací spinner po kliknutí na Yes ⏳
    @State private var startDestruction = false

    var body: some View {
        ZStack {
            // Černé pozadí přes celou obrazovku ⬛️
            Color.black
                .ignoresSafeArea() 
            
            // Zobrazí spinner a text až po kliknutí na "Yes" ✨
            if startDestruction {
                VStack(spacing: 20) {
                    // Skutečný točící se spinner ⏳
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    // Nápis s bílou barvou a hezkým systémovým fontem 🔤
                    Text("Restarting iOS...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        // Nativní alert okno 🚨
        .alert("SwiftyApp", isPresented: $showingAlert) {
            Button("Yes") {
                // Spustí animaci restartu/destrukce 😈
                startDestruction = true
            }
            Button("No", role: .cancel) {
                // Okamžitě ukončí aplikaci 🚪🏃‍♂️
                exit(0)
            }
        } message: {
            Text("Start iOS Destruction?")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
