import SwiftUI

struct ContentView: View {
    private var rootImage: UIImage? {
        if let path = Bundle.main.path(forResource: "A90JUMPSCARE", ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }

    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            
            if let uiImage = rootImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .ignoresSafeArea()
            } else {
                Text("Image not found in root")
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
