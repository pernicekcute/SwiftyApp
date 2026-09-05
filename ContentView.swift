import SwiftUI

struct ContentView: View {
    @State private var iPadOSUIEnabled = true
    @State private var showWarning = false
    @State private var showAbout = false

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
                
                Section {
                    Button {
                        showAbout = true
                    } label: {
                        HStack {
                            Text("About SwiftyApp")
                                .foregroundStyle(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Shows a dialog about the app")
                }
            }
            .navigationTitle("SwiftyApp")
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

            .alert(
                "About",
                isPresented: $showAbout
            ) {
                Button("Close", role: .cancel) {
                }
            } message: {
                Text("SwiftyApp is an app designed for development and ui, @pernicekcute developed this app for over a month and over 300 commits.")
            }
        }
    }
}

#Preview {
    ContentView()
}
