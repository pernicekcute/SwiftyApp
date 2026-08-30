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
            
            // Floating Button positioned on the left, right above the expandable sheet
            Button(action: {
                print("Floating top-left button tapped!")
            }) {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(14)
            }
            .buttonStyle(.glass)
            .padding(.leading, 20)
            .padding(.bottom, 100) // Positioned nicely above the 80pt sheet
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
    @State private var sliderValue: Double = 50
    @State private var toggleValue: Bool = false
    @State private var textValue: String = ""
    @State private var showProfile = false
    
    @Binding var selectedDetent: PresentationDetent
    @Binding var userName: String
    @Binding var userEmail: String

    var body: some View {
        VStack(spacing: 0) {
            
            if selectedDetent == .height(80) {
                Spacer()
                HStack(alignment: .center, spacing: 15) {
                    Slider(value: $sliderValue, in: 0...100)
                        .tint(.blue)
                    
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.glass)
                }
                .padding(.horizontal)
                Spacer()
            } else {
                HStack(alignment: .center, spacing: 15) {
                    Slider(value: $sliderValue, in: 0...100)
                        .tint(.blue)
                    
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.glass)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            if selectedDetent != .height(80) {
                Divider()
                
                // Everything under the divider is contained inside a Form
                Form {
                    Section(header: Text("Settings & Input")) {
                        Toggle("Enable super feature", isOn: $toggleValue)
                        
                        TextField("Type something here...", text: $textValue)
                    }
                    
                    Section {
                        Button(action: {
                            print("Button tapped!")
                        }) {
                            Text("Click me!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.glass)
                        .listRowBackground(Color.blue)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail)
                .presentationDetents([.medium])
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
