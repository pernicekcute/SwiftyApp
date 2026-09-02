import SwiftUI
import MapKit
import Network

// MARK: - Main App View
struct ContentView: View {
    @State private var showSheet = true
    @State private var selectedDetent: PresentationDetent = .medium
    
    @State private var userName: String = "Quacky"
    @State private var userEmail: String = "local.mode@app.local"
    
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
            span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
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
                span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
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
            
            // Tab 3: Settings
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
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

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("useiOS26Style") private var useiOS26Style: Bool = true
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(
                header: Text("Appearance"),
                footer: Text("Switch between the legacy opaque style and the iOS 26 translucent look. Requires restarting the app to apply UI changes fully.")
            ) {
                Toggle("iOS 26 Style", isOn: $useiOS26Style)
                    .onChange(of: useiOS26Style) { _, newValue in
                        ThemeManager.applyTheme(useiOS26Style: newValue)
                        showAlert = true
                    }
            }
        }
        .alert("Restart Required", isPresented: $showAlert) {
            Button("Restart Now", role: .destructive) {
                exit(0)
            }
        } message: {
            Text("The app needs to close to re-initialize system bars. Please open it manually again.")
        }
    }
}
