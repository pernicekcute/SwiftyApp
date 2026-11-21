import SwiftUI

struct ContentView: View {
    // State controllers for different iOS modals & sheets
    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var showStandardSheet = false
    @State private var showHalfSheet = false
    @State private var showFullScreenCover = false
    @State private var showPopover = false
    
    @State private var statusMessage = "Select a component element below to launch it."
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status banner tracking interaction
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text(statusMessage)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Gallery Grid layout representing various iOS UI elements
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        
                        // 1. Alert Dialog Button
                        GalleryCard(title: "Alert Dialog", icon: "exclamationmark.bubble.fill", color: .red) {
                            showAlert = true
                        }
                        
                        // 2. Confirmation Dialog (Action Sheet)
                        GalleryCard(title: "Confirmation Dialog", icon: "list.bullet.rectangle", color: .orange) {
                            showConfirmation = true
                        }
                        
                        // 3. Standard Bottom Sheet
                        GalleryCard(title: "Bottom Sheet (Standard)", icon: "rectangle.bottomthird.inset.filled", color: .blue) {
                            showStandardSheet = true
                        }
                        
                        // 4. Half & Resizable Detent Sheet
                        GalleryCard(title: "Interactive Detent Sheet", icon: "arrow.up.and.down.text.horizontal", color: .purple) {
                            showHalfSheet = true
                        }
                        
                        // 5. Full Screen Cover
                        GalleryCard(title: "Full Screen Cover", icon: "ipad.gen2", color: .indigo) {
                            showFullScreenCover = true
                        }
                        
                        // 6. Popover
                        GalleryCard(title: "Popover View", icon: "square.fill.and.line.vertical.and.square.fill", color: .green) {
                            showPopover = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("iOS Component Gallery")
            
            // MARK: - Modals & Dialog Modifiers Implementation
            
            // 1. Alert
            .alert("System Alert", isPresented: $showAlert) {
                Button("Delete", role: .destructive) {
                    statusMessage = "Alert: Item deleted successfully."
                }
                Button("Cancel", role: .cancel) {
                    statusMessage = "Alert: Action cancelled."
                }
            } message: {
                Text("This is a native iOS interruption alert dialog.")
            }
            
            // 2. Confirmation Dialog (Action Sheet)
            .confirmationDialog("Choose Action", isPresented: $showConfirmation, titleVisibility: .visible) {
                Button("Share Item") { statusMessage = "Confirmation: Share selected." }
                Button("Mark as Favorite") { statusMessage = "Confirmation: Favorited." }
                Button("Delete Item", role: .destructive) { statusMessage = "Confirmation: Item deleted." }
                Button("Cancel", role: .cancel) { }
            }
            
            // 3. Standard Bottom Sheet (.sheet)
            .sheet(isPresented: $showStandardSheet) {
                SheetContentView(title: "Standard Bottom Sheet")
            }
            
            // 4. Detent Sheet (Half-screen / Medium & Large)
            .sheet(isPresented: $showHalfSheet) {
                SheetContentView(title: "Resizable Detent Sheet")
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            
            // 5. Full Screen Cover
            .fullScreenCover(isPresented: $showFullScreenCover) {
                FullScreenCoverView()
            }
            
            // 6. Popover
            .popover(isPresented: $showPopover) {
                VStack(spacing: 12) {
                    Text("Popover Menu")
                        .font(.headline)
                    Text("Adapts to a sheet on compact iPhones or a floating bubble on iPads.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(width: 250, height: 150)
            }
        }
    }
}

// MARK: - Reusable Gallery Card View
struct GalleryCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.fontStyleForCard) // fallback styling via system font
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Helper Views for Sheets & FullScreen
struct SheetContentView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.title2.bold())
                Text("Swipe down or tap the Done button to close this sheet view.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FullScreenCoverView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.indigo.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                Text("Full Screen Cover View")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("This completely takes over the screen space, perfect for immersive flows or onboarding setups.")
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss Cover")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(.white)
                        .foregroundStyle(.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
