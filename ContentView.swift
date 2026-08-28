import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Černé pozadí přes celou obrazovku ⬛️
            Color.black
                .ignoresSafeArea() 
            
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
