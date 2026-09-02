import SwiftUI
import MapKit
import Network

// MARK: - Main App View
struct ContentView: View {
    @State private var showSheet = true
    @State private var selectedDetent: PresentationDetent = .height(80)
    
    @State private var userName: String = "Quacky"
    @State private var userEmail: String = "local.mode@app.local"
    
    // Location and network manager
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background map: dynamically picks satellite (when on Wi-Fi / cellular) or standard (when offline)
            Map(position: $locationManager.cameraPosition, interactionModes: []) {
                // You can add map markers or overlays here if needed
            }
            .mapStyle(locationManager.isOnline ? .imagery : .standard)
            .ignoresSafeArea()
            
            // Subtle overlay for better interface legibility over the map
            Color.black.opacity(0.1)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showSheet) {
            BottomSheetView(
                selectedDetent: $selectedDetent,
                userName: $userName,
                userEmail: $userEmail
            )
            .presentationDetents([.height(80), .medium, .large], selection: $selectedDetent)
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
            center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378), // Default (Prague)
            span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)   // Very close zoom (~12 meters)
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
        manager.requestWhenInUseAuthorization() // Requests location permission from the user
        manager.startUpdatingLocation()
    }

    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // Checks whether Wi-Fi or cellular data is active
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
        // Updates the map camera precisely to the user's location while maintaining a ~12m zoom
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
    @State private var rawLines: [String] = []
    @State private var isLoading: Bool = false
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        NavigationStack {
            Form {
                if isSearching {
                    if isLoading {
                        Section {
                            ProgressView("Loading data from GitHub.")
                        }
                    } else {
                        Section {
                            ForEach(filteredLines, id: \.self) { line in
                                Text(line)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
        .onChange(of: isSearching) { newValue in
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
