import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = true

    var body: some View {
        NavigationStack {
            VStack {
                Button("Show Sheet") {
                    isSheetPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Main View")
            .sheet(isPresented: $isSheetPresented) {
                VStack(spacing: 20) {
                    Text("Locked Medium Sheet")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This sheet cannot be dismissed by swiping down.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    ContentView()
}
