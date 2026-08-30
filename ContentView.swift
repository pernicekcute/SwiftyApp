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

    var body: some View {
        NavigationStack {
            VStack {
                if selectedDetent != .height(80) {
                    // Zobrazí se pouze v rozbaleném stavu (medium / large) ⚠️📱
                    VStack(spacing: 12) {
                        Image(systemName: "iphone")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("This sheet is undone and is in this state.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                } else {
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
    }
}
