import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Černé pozadí přes celou obrazovku ⬛️
            Color(red: 0, green: 0, blue: 0)
                .ignoresSafeArea() 
            
            // Načítací spinner uprostřed ⏳
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle()) // Bílý spinner, aby byl na černém pozadí vidět ⚪️
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
