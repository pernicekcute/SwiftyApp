import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "swift")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)

            Text("Vítej v iOsApp! 🦆🔥")
                .font(.title)
                .bold()

            Text("Sestaveno přes GitHub Actions ✨")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
