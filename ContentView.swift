import SwiftUI

struct ContentView: View {
    // State variables to control the presentation of each modal
    @State private var showAlert = false
    @State private var showConfirmationDialog = false
    @State private var showBottomSheet = false
    
    // State to display feedback from user actions
    @State private var statusMessage = "Tap a button below to trigger a modal."
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Status display
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 1. Trigger for Alert (Dialog)
                Button {
                    showAlert = true
                } label: {
                    Label("Show Alert Dialog", systemImage: "exclamationmark.triangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                // 2. Trigger for Confirmation Dialog
                Button {
                    showConfirmationDialog = true
                } label: {
                    Label("Show Confirmation Dialog", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                // 3. Trigger for Bottom Sheet
                Button {
                    showBottomSheet = true
                } label: {
                    Label("Show Bottom Sheet", systemImage: "rectangle.bottomthird.inset.filled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("SwiftUI Modals")
            
            // MARK: - 1. Alert (Standard Dialog)
            .alert("Important Notice", isPresented: $showAlert) {
                Button("Confirm", role: .destructive) {
                    statusMessage = "Alert: Confirmed destructive action."
                }
                Button("Cancel", role: .cancel) {
                    statusMessage = "Alert: Cancelled."
                }
            } message: {
                Text("Are you sure you want to proceed? This is a standard alert dialog.")
            }
            
            // MARK: - 2. Confirmation Dialog (Action Sheet)
            .confirmationDialog(
                "Choose an Option",
                isPresented: $showConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Save Draft") {
                    statusMessage = "Confirmation: Draft saved."
                }
                Button("Delete Permanently", role: .destructive) {
                    statusMessage = "Confirmation: Item deleted."
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select an action to perform on this item.")
            }
            
            // MARK: - 3. Bottom Sheet
            .sheet(isPresented: $showBottomSheet) {
                BottomSheetView(statusMessage: $statusMessage)
                    // Controls the height of the bottom sheet (iOS 16+)
                    .presentationDetents([.medium, .large])
                    // Shows the grabber handle at the top
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Bottom Sheet Content View
struct BottomSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var statusMessage: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("Custom Bottom Sheet")
                    .font(.title2.bold())
                
                Text("Drag the handle at the top to expand to full screen, or swipe down to dismiss.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Complete Action & Dismiss") {
                    statusMessage = "Bottom Sheet: Action completed!"
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding(.top, 24)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
