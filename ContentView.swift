import SwiftUI

struct ContentView: View {
    // Load the image directly from the main app bundle
    private var rootImage: UIImage? {
        if let path = Bundle.main.path(forResource: "A90JUMPSCARE", ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }

    var body: some View {
        ZStack {
            // Fullscreen red background
            Color.red
                .ignoresSafeArea()
            
            // Render the image if found in the main bundle
            if let uiImage = rootImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .ignoresSafeArea()
            } else {
                // Temporary fallback text if the file is still missing from the bundle
                Text("Image not found in root")
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
