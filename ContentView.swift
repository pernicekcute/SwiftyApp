import SwiftUI

// MARK: - Dev Panel Item Model
struct DevControlItem: Identifiable {
    let id = UUID()
    let index: Int
    let title: String
    let subtitle: String
    let category: DevCategory
    let icon: String
    let color: Color
    let actionType: DevActionType
}

enum DevCategory: String, CaseIterable, Identifiable {
    case all = "All (96)"
    case dialogs = "Dialogs & Alerts"
    case sheets = "Sheets & Covers"
    case menus = "Menus & Popovers"
    case controls = "Inputs & Controls"
    case feedback = "Toasts & Haptics"
    case system = "System & Debug"
    
    var id: String { rawValue }
}

enum DevActionType {
    case alert(title: String, message: String, destructive: Bool, hasTextField: Bool = false)
    case confirmation(title: String, options: [String], hasDestructive: Bool = true)
    case sheet(title: String, detents: Set<PresentationDetent>, showGrabber: Bool = true, interactiveDismiss: Bool = true, bgStyle: SheetBGStyle = .standard)
    case fullScreen(title: String, color: Color)
    case popover(title: String, detail: String)
    case toast(message: String, icon: String, color: Color)
    case haptic(UINotificationFeedbackGenerator.FeedbackType?, UIImpactFeedbackGenerator.FeedbackStyle?)
    case customDialog(title: String, message: String)
    case inspector
    case shareSheet(text: String)
    case fileImporter
    case photosPickerMock
    case stateMutation(log: String)
}

enum SheetBGStyle {
    case standard, ultraThin, clear
}

// MARK: - Main Dev Panel View
struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategory: DevCategory = .all
    @State private var eventLog: [String] = ["[00:00] Dev Panel initialized with 96 iOS triggers."]
    
    // Presentation States
    @State private var activeAlert: (title: String, message: String, destructive: Bool, hasTextField: Bool)?
    @State private var showAlert = false
    @State private var alertInputText = ""
    
    @State private var activeConfirmation: (title: String, options: [String], hasDestructive: Bool)?
    @State private var showConfirmation = false
    
    @State private var activeSheet: (title: String, detents: Set<PresentationDetent>, showGrabber: Bool, interactiveDismiss: Bool, bgStyle: SheetBGStyle)?
    @State private var showSheet = false
    
    @State private var activeFullScreen: (title: String, color: Color)?
    @State private var showFullScreen = false
    
    @State private var activePopover: (title: String, detail: String)?
    @State private var showPopover = false
    
    @State private var customOverlayDialog: (title: String, message: String)?
    @State private var toastBanner: (message: String, icon: String, color: Color)?
    
    @State private var showInspector = false
    @State private var showShareSheet = false
    @State private var shareText = ""
    @State private var showFileImporter = false
    
    // Live Interactive Controls States (for inline Dev section)
    @State private var devToggle1 = true
    @State private var devToggle2 = false
    @State private var devSlider: Double = 0.65
    @State private var devStepper: Int = 4
    @State private var devSegment: Int = 0
    @State private var devColor: Color = .blue
    @State private var devDate = Date()
    @State private var devText = "env=staging"
    
    // 96 Total Dev Items
    private let items: [DevControlItem] = Self.buildCatalog()
    
    private var filteredItems: [DevControlItem] {
        items.filter { item in
            let matchesCategory = (selectedCategory == .all || item.category == selectedCategory)
            let matchesSearch = searchText.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.subtitle.localizedCaseInsensitiveContains(searchText) ||
                "\(item.index)".contains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                List {
                    // MARK: - Console & Telemetry Header
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("LIVE CONSOLE", systemImage: "terminal.fill")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                                Spacer()
                                Button("Clear") {
                                    eventLog = ["Console cleared."]
                                }
                                .font(.caption2)
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(eventLog.prefix(5), id: \.self) { line in
                                        Text(line)
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .frame(height: 68)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // MARK: - Category Filter Chips
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(DevCategory.allCases) { cat in
                                    Button {
                                        selectedCategory = cat
                                    } label: {
                                        Text(cat.rawValue)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedCategory == cat ? Color.blue : Color(.secondarySystemFill))
                                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    }
                    
                    // MARK: - Live Inline Native Controls Sandbox
                    if selectedCategory == .all || selectedCategory == .controls {
                        Section("Live Native Controls Sandbox (8 Inline Widgets)") {
                            Toggle("Feature Flag: New Renderer", isOn: $devToggle1)
                                .onChange(of: devToggle1) { _, v in log("Toggle Renderer = \(v)") }
                            
                            Toggle("Force Offline Mode", isOn: $devToggle2)
                                .tint(.orange)
                                .onChange(of: devToggle2) { _, v in log("Offline Mode = \(v)") }
                            
                            VStack(alignment: .leading) {
                                Text("Animation Speed: \(String(format: "%.2fx", devSlider))")
                                    .font(.caption)
                                Slider(value: $devSlider, in: 0.1...2.0)
                            }
                            
                            Stepper("Retry Count: \(devStepper)", value: $devStepper, in: 0...10)
                            
                            Picker("Environment", selection: $devSegment) {
                                Text("Dev").tag(0)
                                Text("Stage").tag(1)
                                Text("Prod").tag(2)
                            }
                            .pickerStyle(.segmented)
                            
                            ColorPicker("Accent Override", selection: $devColor)
                            
                            DatePicker("Mock System Clock", selection: $devDate)
                                .font(.subheadline)
                            
                            HStack {
                                Text("Payload:")
                                    .font(.subheadline)
                                TextField("Query string", text: $devText)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                    
                    // MARK: - 96 Triggerable iOS Components
                    Section("Triggers (\(filteredItems.count) of \(items.count))") {
                        ForEach(filteredItems) { item in
                            HStack(spacing: 12) {
                                Text(String(format: "#%02d", item.index))
                                    .font(.system(.caption2, design: .monospaced).bold())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28)
                                
                                Image(systemName: item.icon)
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(item.color)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Special inline ContextMenu / Menu support for menu items
                                if item.index == 49 {
                                    Menu("Open") {
                                        Button("Action 1") { log("Menu: Action 1") }
                                        Button("Action 2") { log("Menu: Action 2") }
                                        Divider()
                                        Button("Delete", role: .destructive) { log("Menu: Delete") }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                } else {
                                    Button("Run") {
                                        trigger(item)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(item.color)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 2)
                            .contextMenu {
                                Button("Trigger #\(item.index)") { trigger(item) }
                                Button("Copy Component Name") {
                                    UIPasteboard.general.string = item.title
                                    log("Copied '\(item.title)' to clipboard")
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search 96 iOS dialogs, sheets, haptics...")
                
                // MARK: - Top Floating Toast Overlay
                if let toast = toastBanner {
                    HStack(spacing: 10) {
                        Image(systemName: toast.icon)
                            .foregroundStyle(.white)
                        Text(toast.message)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(toast.color.gradient)
                    .clipShape(Capsule())
                    .shadow(radius: 8)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                }
                
                // MARK: - Custom Centered Modal Dialog Overlay
                if let custom = customOverlayDialog {
                    ZStack {
                        Color.black.opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation { customOverlayDialog = nil }
                            }
                        
                        VStack(spacing: 16) {
                            Image(systemName: "cpu.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)
                            Text(custom.title)
                                .font(.headline)
                            Text(custom.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Button("Dismiss") {
                                    withAnimation { customOverlayDialog = nil }
                                    log("Custom Overlay dismissed")
                                }
                                .buttonStyle(.bordered)
                                
                                Button("Execute") {
                                    withAnimation { customOverlayDialog = nil }
                                    log("Custom Overlay executed")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: 310)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 20)
                    }
                    .zIndex(20)
                }
            }
            .navigationTitle("iOS Dev Panel (96)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Trigger Random Component") {
                            if let random = items.randomElement() { trigger(random) }
                        }
                        Button("Show Inspector") { showInspector.toggle() }
                        Button("Reset Console") { eventLog = ["Console reset."] }
                    } label: {
                        Image(systemName: "wrench.and.screwdriver.fill")
                    }
                }
            }
            // MARK: - 1. Native Alert Modifier
            .alert(activeAlert?.title ?? "Alert", isPresented: $showAlert) {
                if activeAlert?.hasTextField == true {
                    TextField("Enter value...", text: $alertInputText)
                }
                if activeAlert?.destructive == true {
                    Button("Confirm Delete", role: .destructive) {
                        log("Alert confirmed (destructive): \(alertInputText)")
                        alertInputText = ""
                    }
                } else {
                    Button("OK") {
                        log("Alert confirmed: \(alertInputText)")
                        alertInputText = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    log("Alert cancelled")
                    alertInputText = ""
                }
            } message: {
                Text(activeAlert?.message ?? "")
            }
            // MARK: - 2. Native Confirmation Dialog Modifier
            .confirmationDialog(
                activeConfirmation?.title ?? "Confirm",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                if let options = activeConfirmation?.options {
                    ForEach(options, id: \.self) { opt in
                        Button(opt) {
                            log("ConfirmationDialog selected: \(opt)")
                        }
                    }
                }
                if activeConfirmation?.hasDestructive == true {
                    Button("Destructive Action", role: .destructive) {
                        log("ConfirmationDialog: Destructive Action")
                    }
                }
                Button("Cancel", role: .cancel) {
                    log("ConfirmationDialog cancelled")
                }
            } message: {
                Text("Select an option from the native action sheet.")
            }
            // MARK: - 3. Native Sheet / Bottom Sheet Modifier
            .sheet(isPresented: $showSheet) {
                if let sheet = activeSheet {
                    DevBottomSheetView(title: sheet.title, detentsCount: sheet.detents.count) { msg in
                        log(msg)
                    }
                    .presentationDetents(sheet.detents)
                    .presentationDragIndicator(sheet.showGrabber ? .visible : .hidden)
                    .interactiveDismissDisabled(!sheet.interactiveDismiss)
                    .presentationBackground(sheetBackground(sheet.bgStyle))
                }
            }
            // MARK: - 4. Full Screen Cover Modifier
            .fullScreenCover(isPresented: $showFullScreen) {
                if let fs = activeFullScreen {
                    DevFullScreenView(title: fs.title, color: fs.color) {
                        log("Closed FullScreen: \(fs.title)")
                    }
                }
            }
            // MARK: - 5. Popover Modifier
            .popover(isPresented: $showPopover) {
                VStack(spacing: 10) {
                    Text(activePopover?.title ?? "Popover")
                        .font(.headline)
                    Text(activePopover?.detail ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(width: 240, height: 130)
                .presentationCompactAdaptation(.popover)
            }
            // MARK: - 6. Inspector Modifier (iOS 17+)
            .inspector(isPresented: $showInspector) {
                VStack(spacing: 16) {
                    Text("SwiftUI .inspector")
                        .font(.headline)
                    Text("Side panel on iPad/Mac, automatic sheet on iPhone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Close Inspector") { showInspector = false }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            // MARK: - 7. Share Sheet (UIActivityViewController)
            .sheet(isPresented: $showShareSheet) {
                ActivityView(text: shareText)
                    .presentationDetents([.medium, .large])
            }
            // MARK: - 8. Native File Importer
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item]) { result in
                switch result {
                case .success(let url): log("File picked: \(url.lastPathComponent)")
                case .failure(let err): log("File error: \(err.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Trigger Router
    private func trigger(_ item: DevControlItem) {
        log("Triggered #\(item.index): \(item.title)")
        
        switch item.actionType {
        case let .alert(title, message, destructive, hasTextField):
            activeAlert = (title, message, destructive, hasTextField)
            showAlert = true
            
        case let .confirmation(title, options, hasDestructive):
            activeConfirmation = (title, options, hasDestructive)
            showConfirmation = true
            
        case let .sheet(title, detents, showGrabber, interactiveDismiss, bgStyle):
            activeSheet = (title, detents, showGrabber, interactiveDismiss, bgStyle)
            showSheet = true
            
        case let .fullScreen(title, color):
            activeFullScreen = (title, color)
            showFullScreen = true
            
        case let .popover(title, detail):
            activePopover = (title, detail)
            showPopover = true
            
        case let .toast(message, icon, color):
            withAnimation(.spring) {
                toastBanner = (message, icon, color)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { toastBanner = nil }
            }
            
        case let .haptic(notif, impact):
            if let notif {
                UINotificationFeedbackGenerator().notificationOccurred(notif)
            }
            if let impact {
                UIImpactFeedbackGenerator(style: impact).impactOccurred()
            }
            
        case let .customDialog(title, message):
            withAnimation(.spring(duration: 0.25)) {
                customOverlayDialog = (title, message)
            }
            
        case .inspector:
            showInspector.toggle()
            
        case let .shareSheet(text):
            shareText = text
            showShareSheet = true
            
        case .fileImporter:
            showFileImporter = true
            
        case .photosPickerMock:
            activeSheet = ("Photos Picker Simulation", [.medium, .large], true, true, .standard)
            showSheet = true
            
        case let .stateMutation(msg):
            log(msg)
        }
    }
    
    private func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let stamp = formatter.string(from: Date())
        eventLog.insert("[\(stamp)] \(message)", at: 0)
    }
    
    private func sheetBackground(_ style: SheetBGStyle) -> AnyShapeStyle {
        switch style {
        case .standard: return AnyShapeStyle(.background)
        case .ultraThin: return AnyShapeStyle(.ultraThinMaterial)
        case .clear: return AnyShapeStyle(.thinMaterial)
        }
    }
}

// MARK: - Reusable Bottom Sheet View
struct DevBottomSheetView: View {
    let title: String
    let detentsCount: Int
    let onLog: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "rectangle.bottomthird.inset.filled")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                
                Text("Active detents configured: \(detentsCount). Drag grabber or tap dismiss below.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Emit Event & Close") {
                    onLog("Sheet '\(title)' emitted event")
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding(.top, 24)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reusable Full Screen Cover View
struct DevFullScreenView: View {
    let title: String
    let color: Color
    let onClose: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            color.gradient.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "macwindow.on.rectangle")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text("Full-screen modal presentation blocking background interaction.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button("Close Full Screen") {
                    onClose()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(color)
            }
        }
    }
}

// MARK: - UIKit Activity Share Sheet Wrapper
struct ActivityView: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 96-Item Catalog Builder
extension ContentView {
    static func buildCatalog() -> [DevControlItem] {
        var list: [DevControlItem] = []
        var idx = 1
        func add(_ title: String, _ sub: String, _ cat: DevCategory, _ icon: String, _ color: Color, _ action: DevActionType) {
            list.append(DevControlItem(index: idx, title: title, subtitle: sub, category: cat, icon: icon, color: color, actionType: action))
            idx += 1
        }
        
        // 1 - 16: Dialogs & Alerts (16 items)
        add("Standard Alert", "Basic title, message & OK button", .dialogs, "exclamationmark.circle", .blue,
            .alert(title: "Notice", message: "Standard iOS system alert.", destructive: false))
        add("Destructive Alert", "Red destructive action + Cancel", .dialogs, "trash.fill", .red,
            .alert(title: "Delete Record?", message: "This action cannot be undone.", destructive: true))
        add("Text Input Alert", "Alert with embedded TextField", .dialogs, "character.cursor.ibeam", .indigo,
            .alert(title: "Rename Item", message: "Enter a new identifier:", destructive: false, hasTextField: true))
        add("Password Prompt Alert", "Simulated credential alert", .dialogs, "key.fill", .orange,
            .alert(title: "Authentication Required", message: "Enter admin PIN to continue.", destructive: false, hasTextField: true))
        add("Network Timeout Alert", "Simulated HTTP 504 error", .dialogs, "wifi.slash", .red,
            .alert(title: "Connection Lost", message: "The server stopped responding (504).", destructive: false))
        add("Permission Denied Alert", "Camera/Location privacy prompt", .dialogs, "lock.shield", .purple,
            .alert(title: "Access Denied", message: "Enable permissions in iOS Settings.", destructive: false))
        add("Confirmation Dialog (3 Opts)", "Standard bottom action sheet", .dialogs, "list.bullet", .orange,
            .confirmation(title: "Choose Export Format", options: ["JSON", "CSV", "PDF"]))
        add("Confirmation Dialog (5 Opts)", "Multi-choice action sheet", .dialogs, "list.number", .teal,
            .confirmation(title: "Select Environment", options: ["Localhost", "Dev", "QA", "Staging", "Production"]))
        add("Destructive Confirmation", "Action sheet with red delete", .dialogs, "xmark.bin.fill", .red,
            .confirmation(title: "Purge Cache?", options: ["Clear Images Only"], hasDestructive: true))
        add("Non-Destructive Confirmation", "Safe action sheet choices", .dialogs, "checkmark.seal", .green,
            .confirmation(title: "Sort Order", options: ["Newest First", "Oldest First", "Alphabetical"], hasDestructive: false))
        add("Custom Blur Dialog", "Centered material card overlay", .dialogs, "sparkles.square.filled.on.square", .blue,
            .customDialog(title: "Custom Material Dialog", message: "Rendered with .regularMaterial and spring animation."))
        add("Custom Warning Card", "Custom floating warning modal", .dialogs, "exclamationmark.triangle.fill", .yellow,
            .customDialog(title: "Memory Warning", message: "Heap allocation exceeded 85% threshold."))
        add("Force Update Dialog", "Blocking version check modal", .dialogs, "arrow.down.app.fill", .indigo,
            .customDialog(title: "Update Required", message: "Build 2026.11 is required to connect."))
        add("Rate App Prompt", "Simulated SKStoreReview dialog", .dialogs, "star.fill", .orange,
            .alert(title: "Enjoying Dev Panel?", message: "Tap OK to simulate a 5-star review.", destructive: false))
        add("Sign Out Confirmation", "Account session termination", .dialogs, "rectangle.portrait.and.arrow.right", .red,
            .confirmation(title: "Sign Out of All Devices?", options: ["Sign Out Current Device"], hasDestructive: true))
        add("Unsaved Changes Dialog", "Discard vs Save prompt", .dialogs, "doc.badge.ellipsis", .purple,
            .confirmation(title: "You have unsaved changes", options: ["Save Draft", "Keep Editing"], hasDestructive: true))
        
        // 17 - 32: Sheets & Full-Screen Covers (16 items)
        add("Standard Sheet (.large)", "Default iOS modal card sheet", .sheets, "rectangle.portrait.bottomhalf.filled", .blue,
            .sheet(title: "Standard Large Sheet", detents: [.large]))
        add("Half Bottom Sheet (.medium)", "50% height bottom sheet", .sheets, "rectangle.bottomhalf.filled", .indigo,
            .sheet(title: "Medium Half Sheet", detents: [.medium]))
        add("Resizable Sheet (.medium, .large)", "Expandable two-stage sheet", .sheets, "arrow.up.and.down", .purple,
            .sheet(title: "Expandable Bottom Sheet", detents: [.medium, .large]))
        add("Compact Sheet (.fraction(0.25))", "25% height mini bottom sheet", .sheets, "rectangle.bottomthird.inset.filled", .teal,
            .sheet(title: "Quarter Height Sheet", detents: [.fraction(0.25), .medium]))
        add("Fixed Height Sheet (180pt)", "Exact point height detent", .sheets, "ruler", .cyan,
            .sheet(title: "180pt Fixed Sheet", detents: [.height(180)]))
        add("3-Stage Detent Sheet", "25% -> 50% -> 100% detents", .sheets, "slider.vertical.3", .mint,
            .sheet(title: "3-Stage Detent Sheet", detents: [.fraction(0.25), .medium, .large]))
        add("Hidden Grabber Sheet", "Bottom sheet without drag pill", .sheets, "minus", .gray,
            .sheet(title: "No Drag Indicator Sheet", detents: [.medium], showGrabber: false))
        add("Non-Dismissible Sheet", "Blocks swipe-down dismissal", .sheets, "lock.fill", .red,
            .sheet(title: "Locked Modal Sheet", detents: [.medium], interactiveDismiss: false))
        add("UltraThin Material Sheet", "Translucent frosted glass sheet", .sheets, "aqi.medium", .blue,
            .sheet(title: "UltraThin Material Sheet", detents: [.medium, .large], bgStyle: .ultraThin))
        add("Thin Material Sheet", "Subtle translucent sheet background", .sheets, "drop.fill", .cyan,
            .sheet(title: "Thin Material Sheet", detents: [.medium], bgStyle: .clear))
        add("Full Screen Cover (Indigo)", "Edge-to-edge modal takeover", .sheets, "ipad", .indigo,
            .fullScreen(title: "Immersive Onboarding", color: .indigo))
        add("Full Screen Cover (Crimson)", "Critical takeover screen", .sheets, "exclamationmark.octagon.fill", .red,
            .fullScreen(title: "System Lockdown", color: .red))
        add("Full Screen Cover (Emerald)", "Success flow takeover", .sheets, "checkmark.circle.fill", .green,
            .fullScreen(title: "Setup Complete", color: .green))
        add("Native Share Sheet", "UIActivityViewController", .sheets, "square.and.arrow.up", .blue,
            .shareSheet(text: "Exported from iOS Dev Panel (96)"))
        add("Native File Importer", "UIDocumentPickerViewController", .sheets, "folder.fill", .orange,
            .fileImporter)
        add("Photos Picker Sheet", "Simulated PHPicker sheet", .sheets, "photo.on.rectangle", .pink,
            .photosPickerMock)
        
        // 33 - 48: Menus, Popovers & Inspectors (16 items)
        add("Standard Popover", "Floating bubble on iPad / compact", .menus, "bubble.middle.bottom.fill", .green,
            .popover(title: "Info Popover", detail: "Uses .presentationCompactAdaptation(.popover)"))
        add("Debug Stats Popover", "FPS & memory popover", .menus, "gauge.with.needle", .orange,
            .popover(title: "60 FPS | 42 MB", detail: "Main thread idle: 94%"))
        add("Tooltip Popover", "Contextual hint bubble", .menus, "questionmark.circle.fill", .blue,
            .popover(title: "Quick Tip", detail: "Long-press any row in this list for a ContextMenu!"))
        add("SwiftUI Inspector Panel", "Toggle .inspector side/bottom pane", .menus, "sidebar.right", .purple,
            .inspector)
        add("Inline Dropdown Menu", "Tap 'Open' button on this row", .menus, "filemenu.and.selection", .indigo,
            .toast(message: "Tap the 'Open' menu button on row #49!", icon: "hand.tap.fill", color: .indigo))
        for i in 1...11 {
            add("Popover Preset #\(i)", "Compact floating anchor test \(i)", .menus, "macwindow", .teal,
                .popover(title: "Preset #\(i)", detail: "Dynamic popover content payload #\(i)."))
        }
        
        // 49 - 64: Haptics & Tactile Feedback (16 items)
        add("Haptic: Success", "UINotificationFeedback (.success)", .feedback, "checkmark.circle", .green,
            .haptic(.success, nil))
        add("Haptic: Warning", "UINotificationFeedback (.warning)", .feedback, "exclamationmark.triangle", .orange,
            .haptic(.warning, nil))
        add("Haptic: Error", "UINotificationFeedback (.error)", .feedback, "xmark.octagon", .red,
            .haptic(.error, nil))
        add("Haptic: Impact Light", "UIImpactFeedback (.light)", .feedback, "feather", .cyan,
            .haptic(nil, .light))
        add("Haptic: Impact Medium", "UIImpactFeedback (.medium)", .feedback, "circle.circle", .blue,
            .haptic(nil, .medium))
        add("Haptic: Impact Heavy", "UIImpactFeedback (.heavy)", .feedback, "hammer.fill", .indigo,
            .haptic(nil, .heavy))
        add("Haptic: Impact Soft", "UIImpactFeedback (.soft)", .feedback, "cloud.fill", .mint,
            .haptic(nil, .soft))
        add("Haptic: Impact Rigid", "UIImpactFeedback (.rigid)", .feedback, "cube.fill", .purple,
            .haptic(nil, .rigid))
        add("Toast: Info Banner", "Floating top pill notification", .feedback, "info.circle.fill", .blue,
            .toast(message: "Sync completed in 120ms", icon: "checkmark.circle.fill", color: .blue))
        add("Toast: Success Banner", "Green confirmation pill", .feedback, "checkmark.seal.fill", .green,
            .toast(message: "Changes saved to disk", icon: "externaldrive.fill.badge.checkmark", color: .green))
        add("Toast: Warning Banner", "Orange rate-limit pill", .feedback, "bolt.fill", .orange,
            .toast(message: "API rate limit at 80%", icon: "exclamationmark.triangle.fill", color: .orange))
        add("Toast: Error Banner", "Red failure pill", .feedback, "wifi.exclamationmark", .red,
            .toast(message: "Socket disconnected", icon: "xmark.circle.fill", color: .red))
        add("Toast: Clipboard Copied", "Pasteboard feedback banner", .feedback, "doc.on.clipboard.fill", .indigo,
            .toast(message: "Copied token to clipboard", icon: "doc.on.clipboard", color: .indigo))
        add("Toast: Dark Capsule", "High-contrast status toast", .feedback, "moon.fill", .black,
            .toast(message: "Dark mode shader active", icon: "moon.stars.fill", color: .black))
        add("Toast: Network Upload", "Background task completion", .feedback, "arrow.up.circle.fill", .teal,
            .toast(message: "Uploaded 4.2 MB telemetry", icon: "icloud.and.arrow.up.fill", color: .teal))
        add("Toast: Feature Unlocked", "Pro entitlement banner", .feedback, "crown.fill", .purple,
            .toast(message: "Developer Pro unlocked", icon: "crown.fill", color: .purple))
        
        // 65 - 80: Controls & State Triggers (16 items)
        for i in 1...16 {
            let names = [
                ("Toggle Theme Override", "Simulate appearance flip", "paintbrush.fill", Color.purple),
                ("Trigger Skeleton Loader", "Simulate shimmer state", "rectangle.dashed", Color.gray),
                ("Simulate Push Payload", "Mock APNs JSON arrival", "bell.badge.fill", Color.red),
                ("Mock Deep Link", "Open myapp://dev/route", "link", Color.blue),
                ("Flush Image Cache", "Evict NSCache entries", "photo.stack", Color.orange),
                ("Reset UserDefaults", "Clear local preference keys", "gearshape.2.fill", Color.red),
                ("Mock Biometric Auth", "Simulate FaceID pass", "faceid", Color.green),
                ("Simulate Low Power Mode", "Throttle background timers", "battery.25", Color.yellow),
                ("Trigger Crash Reporter", "Send non-fatal stack trace", "ladybug.fill", Color.red),
                ("Mock StoreKit Purchase", "Simulate sandbox transaction", "creditcard.fill", Color.indigo),
                ("Toggle Grid Overlay", "Alignment ruler diagnostic", "grid", Color.cyan),
                ("Simulate Location (Prague)", "50.0755° N, 14.4378° E", "location.fill", Color.blue),
                ("Mock Bluetooth Beacon", "Simulate iBeacon proximity", "dot.radiowaves.left.and.right", Color.teal),
                ("Trigger Spotlight Index", "Re-index CoreSpotlight items", "magnifyingglass", Color.indigo),
                ("Simulate CloudKit Sync", "Push dirty records", "icloud.fill", Color.blue),
                ("Dump View Hierarchy", "Log active SwiftUI state", "square.3.layers.3d", Color.purple)
            ]
            let entry = names[i - 1]
            add(entry.0, entry.1, .controls, entry.2, entry.3,
                .stateMutation(log: "Executed state trigger: \(entry.0)"))
        }
        
        // 81 - 96: System & Debug Diagnostics (16 items)
        for i in 1...16 {
            let sys = [
                ("Inspect Bundle ID", "Log CFBundleIdentifier", "shippingbox.fill", Color.brown),
                ("Check OS Version", "ProcessInfo.operatingSystemVersion", "iphone", Color.gray),
                ("Check Thermal State", "Nominal / Fair / Serious / Critical", "thermometer.medium", Color.orange),
                ("Check Processor Count", "Active CPU cores telemetry", "cpu", Color.blue),
                ("Check Physical Memory", "Total device RAM bytes", "memorychip", Color.green),
                ("Check Disk Free Space", "URLResourceValues volume capacity", "internaldrive", Color.indigo),
                ("Check Locale & Timezone", "Current region & calendar", "globe", Color.teal),
                ("Check Dynamic Type Size", "Accessibility font scale", "textformat.size", Color.purple),
                ("Check Reduce Motion", "Accessibility animation flag", "figure.walk", Color.mint),
                ("Check VoiceOver Status", "UIAccessibility.isVoiceOverRunning", "ear.fill", Color.blue),
                ("Inspect Safe Area Insets", "Top & bottom window insets", "inset.filled.topthird.rectangle", Color.cyan),
                ("Ping Health Endpoint", "GET /v1/health -> 200 OK", "heart.text.square.fill", Color.red),
                ("Rotate JWT Token", "Refresh auth bearer credential", "key.viewfinder", Color.orange),
                ("Export Console Logs", "Share session diagnostics", "doc.plaintext.fill", Color.indigo),
                ("Benchmark Main Thread", "Run 10,000 loop micro-test", "stopwatch.fill", Color.pink),
                ("Verify Sandbox Integrity", "Check code signing & entitlements", "checkmark.shield.fill", Color.green)
            ]
            let entry = sys[i - 1]
            add(entry.0, entry.1, .system, entry.2, entry.3,
                .toast(message: "\(entry.0): OK", icon: entry.2, color: entry.3))
        }
        
        return list
    }
}

#Preview {
    ContentView()
}
