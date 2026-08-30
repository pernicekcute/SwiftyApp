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
    @State private var searchText: String = ""
    @State private var showProfile = false
    @State private var rawSearchDatabase: [String] = ["Loading from GitHub... ⏳"]
    
    @Binding var selectedDetent: PresentationDetent
    @Binding var userName: String
    @Binding var userEmail: String

    var filteredResults: [String] {
        if searchText.isEmpty {
            return rawSearchDatabase
        } else {
            return rawSearchDatabase.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if selectedDetent != .height(80) {
                    Divider()
                    
                    // Form displaying the raw text fetched directly from GitHub search.txt
                    Form {
                        if searchText.isEmpty {
                            Section(header: Text("From GitHub (search.txt)")) {
                                ForEach(rawSearchDatabase, id: \.self) { item in
                                    Text(item)
                                }
                            }
                        } else {
                            Section(header: Text("Search Results")) {
                                if filteredResults.isEmpty {
                                    Text("No results found for „\(searchText)“")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(filteredResults, id: \.self) { result in
                                        Text(result)
                                    }
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search…")
            .task {
                await fetchRawSearchFile()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail)
                .presentationDetents([.medium])
        }
    }

    // Function to fetch raw search.txt from GitHub repository asynchronously
    func fetchRawSearchFile() async {
        let urlString = "https://raw.githubusercontent.com/quacky/SwiftyApp/main/search.txt"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let content = String(data: data, encoding: .utf8) {
                let lines = content.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                await MainActor.run {
                    self.rawSearchDatabase = lines.isEmpty ? ["search.txt is empty"] : lines
                }
            }
        } catch {
            await MainActor.run {
                self.rawSearchDatabase = ["Failed to load search.txt from GitHub ❌"]
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 90, height: 90)
                .foregroundColor(.blue)
                .padding(.top, 40)

            Text(userName)
                .font(.title2)
                .fontWeight(.bold)

            Text(userEmail)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Sign in is not available. Running in local mode.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                
            Spacer()
        }
    }
}
