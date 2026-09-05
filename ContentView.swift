import SwiftUI

struct ContentView: View {
    @State private var iPadOSUIEnabled = true
    @State private var showWarning = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showWarning = true
                    } label: {
                        HStack {
                            Text("Test Button")
                                .foregroundStyle(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Shows a test dialog")
                }
            }
            .navigationTitle("SwiftyApp - Nightly Release")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "square.dashed")
                    }
                }
            }

            .alert(
                "SwiftyApp Dialog",
                isPresented: $showWarning
            ) {
                Button("Close", role: .cancel) {
                }

                Button("Continue", role: .destructive) {
                }
            } message: {
                Text("This is a test dialog!")
            }
        }
    }
}

#Preview {
    ContentView()
}
