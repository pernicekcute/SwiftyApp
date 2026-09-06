import SwiftUI
import WebKit

struct ContentView: View {
    @State private var iPadOSUIEnabled = true
    @State private var showWarning = false
    @State private var showAbout = false
    @State private var showRockyOS = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showRockyOS = true
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("Open RockyOS")
                                .foregroundStyle(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Opens RockyOS inside the app")
                }
                
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
            
            .sheet(isPresented: $showRockyOS) {
                NavigationView {
                    WebView(url: URL(string: "https://www.figma.com/proto/UWc2pWPejsjR6xZdPH8NyA/RockyOS?node-id=4004-31&starting-point-node-id=4004%3A31")!)
                        .navigationTitle("RockyOS")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showRockyOS = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    ContentView()
}
