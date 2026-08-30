import SwiftUI
import MapKit
import Network

// MARK: - Hlavní pohled aplikace
struct ContentView: View {
    @State private var showSheet = true
    @State private var selectedDetent: PresentationDetent = .height(80)
    
    @State private var userName: String = "Quacky"
    @State private var userEmail: String = "local.mode@app.local"
    
    // Správce lokace a síťového připojení
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            // Pozadí tvořené mapou: dynamicky volí satelit (při Wi-Fi / datech) nebo standard (při offline)
            Map(position: $locationManager.cameraPosition, interactionModes: []) {
                // Můžeš zde přidat vlastní značky nebo nechat čistou mapu
            }
            .mapStyle(locationManager.isOnline ? .imagery : .standard)
            .ignoresSafeArea()
            
            // Jemný překryv pro lepší čitelnost rozhraní nad mapou
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

// MARK: - Pomocný správce lokace a sítě
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378), // Výchozí (Praha)
            span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)   // Velmi blízký zoom (~12 metrů)
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
        manager.requestWhenInUseAuthorization() // Vyžádá oprávnění k poloze
        manager.startUpdatingLocation()
    }

    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // Kontroluje, zda je aktivní Wi-Fi nebo mobilní data (cellular)
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
        // Aktualizuje kameru mapy přesně na polohu uživatele se zachováním 12m zoomu
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
            )
        )
    }
}

// MARK: - Spodní panel (Bottom Sheet)
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
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            if selectedDetent != .height(80) {
                Divider()
                
                // Všechno pod dividerem je kompletně uvnitř Formu
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

// MARK: - Karta Profilu
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
