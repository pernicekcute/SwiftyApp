import SwiftUI

struct ContentView: View {
    @State private var iPadOSUIEnabled = true
    @State private var showWarning = false

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Jailbreak Software

                Section {
                    Button {
                        // Pouze UI / mockup
                        showWarning = true
                    } label: {
                        HStack {
                            Text("Install Jailbreak")
                                .foregroundStyle(.blue)

                            Spacer()

                            Text("This voids your warranty!")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Text("Jailbreak your Device and also install Cydia")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                } header: {
                    Text("JAILBREAK SOFTWARE")
                }

                // MARK: - iPadOS UI

                Section {
                    HStack {
                        Text("iPadOS UI")
                            .foregroundStyle(.orange)

                        Spacer()

                        Toggle("", isOn: $iPadOSUIEnabled)
                            .labelsHidden()
                    }

                    HStack {
                        Text("Custom Wallpapers")

                        Spacer()

                        Text("Import .tendies")
                            .foregroundStyle(.secondary)

                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                    }

                    if iPadOSUIEnabled {
                        Text("Custom Wallpapers are unavailable with iPadOS UI!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Custom Wallpapers are unavailable right now!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                } header: {
                    Text("iPadOS UI")
                }
            }
            .navigationTitle("SmI3H8t3r")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - Navigation Bar

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Pouze vizuální back button
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("Label")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Pouze placeholder
                    } label: {
                        Image(systemName: "rectangle.on.rectangle")
                    }
                }
            }

            // MARK: - Warning

            .alert(
                "SmI3H8t3r Jailbreak",
                isPresented: $showWarning
            ) {
                Button("Cancel", role: .cancel) {
                    // Zavřít dialog
                }

                Button("Install", role: .destructive) {
                    // Pouze mockup.
                    // Žádná skutečná instalace ani ukončení aplikace.
                }
            } message: {
                Text(
                    "Sm1l3H8t3r will install jailbreak using TrollRestore, BookRestore, and SparseRestore. Back up your device before installing."
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
