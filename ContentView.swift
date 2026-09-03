import SwiftUI
import MapKit
import Network

// MARK: - Main App View
struct ContentView: View {
    @State private var showSheet = true
    @State private var selectedDetent: PresentationDetent = .medium
    
    @State private var userName: String = "SwiftUI"
    @State private var userEmail: String = "SwiftyApp@local"
    
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Map(position: $locationManager.cameraPosition, interactionModes: []) {
            }
            .mapStyle(locationManager.isOnline ? .imagery : .standard)
            .ignoresSafeArea()
            
            Color.black.opacity(0.1)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showSheet) {
            BottomSheetView(
                selectedDetent: $selectedDetent,
                userName: $userName,
                userEmail: $userEmail
            )
            .presentationDetents([.medium, .large], selection: $selectedDetent)
            .presentationBackgroundInteraction(.enabled)
            .interactiveDismissDisabled()
        }
    }
}

// MARK: - Location & Network Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @Published var isOnline: Bool = true

    override init() {
        super.init()
        setupLocationManager()
        setupNetworkMonitor()
    }

    private func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let hasWifiOrCellular = path.usesInterfaceType(.wifi) || path.usesInterfaceType(.cellular)
                self?.isOnline = (path.status == .satisfied && hasWifiOrCellular)
            }
        }
        monitor.start(queue: queue)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
    }
}

// MARK: - Bottom Sheet View
struct BottomSheetView: View {
    @Binding var selectedDetent: PresentationDetent
    @Binding var userName: String
    @Binding var userEmail: String
    
    @State private var searchText: String = ""

    var body: some View {
        TabView {
            // Tab 1: Search
            NavigationStack {
                BottomSheetContentView(searchText: $searchText)
                    .toolbar(.hidden, for: .navigationBar)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            // Tab 2: Profile
            NavigationStack {
                ProfileView(userName: $userName, userEmail: $userEmail)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            
            // Tab 3: Scroll Slider
            NavigationStack {
                ScrollSliderView()
                    .navigationTitle("Scroll Slider")
            }
            .tabItem {
                Label("Slider", systemImage: "timer")
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
    }
}

// MARK: - Scroll-Style Minute Slider View
struct ScrollSliderView: View {
    @State private var selectedMinutes: Int = 15
    @State private var baseOffset: CGFloat = 0

    let tickSpacing: CGFloat = 12
    let maxMinutes = 60

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(selectedMinutes)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.accentColor)
                    .contentTransition(.numericText())
                Text("minutes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ZStack {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 3, height: 40)
                    .cornerRadius(1.5)
                    .zIndex(1)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: tickSpacing) {
                        ForEach(0...maxMinutes, id: \.self) { minute in
                            Rectangle()
                                .fill(minute == selectedMinutes ? Color.accentColor : Color.secondary.opacity(0.4))
                                .frame(width: minute % 5 == 0 ? 3 : 1.5, height: minute % 5 == 0 ? 24 : 14)
                                .cornerRadius(1)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedMinutes = minute
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, UIScreen.main.bounds.width / 2 - 16)
                }
                .scrollDisabled(true)
            }
            .frame(height: 60)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = -value.translation.width + baseOffset
                        let rawIndex = Int(round(translation / tickSpacing))
                        let clamped = max(0, min(maxMinutes, rawIndex))
                        
                        if clamped != selectedMinutes {
                            selectedMinutes = clamped
                        }
                    }
                    .onEnded { _ in
                        baseOffset = CGFloat(selectedMinutes) * tickSpacing
                    }
            )

            Slider(value: Binding(
                get: { Double(selectedMinutes) },
                set: { selectedMinutes = Int($0); baseOffset = CGFloat(selectedMinutes) * tickSpacing }
            ), in: 0...60, step: 1)
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Bottom Sheet Content
struct BottomSheetContentView: View {
    @Binding var searchText: String
    
    @State private var rawLines: [String] = []
    @State private var isLoading: Bool = false
    
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        Group {
            if isSearching {
                Form {
                    if isLoading {
                        Section {
                            ProgressView("Loading data from GitHub...")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        Section {
                            ForEach(filteredLines, id: \.self) { line in
                                Text(line)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Start Searching", systemImage: "magnifyingglass", description: Text("Tap the search bar above"))
            }
        }
        .onChange(of: isSearching) { _, newValue in
            if newValue && rawLines.isEmpty {
                fetchRemoteData()
            }
        }
    }

    var filteredLines: [String] {
        if searchText.isEmpty {
            return rawLines
        } else {
            return rawLines.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func fetchRemoteData() {
        guard let url = URL(string: "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/search.txt") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data, let content = String(data: data, encoding: .utf8) else { return }
                
                rawLines = content.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            }
        }.resume()
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $userName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    TextField("Email", text: $userEmail)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
