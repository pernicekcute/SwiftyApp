import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var showSheet = true
    
    // 📏 Nastaveno na přesnou výšku 80, což je úplně to nejmenší pro Slider a profilovku!
    @State private var selectedDetent: PresentationDetent = .height(80)
    
    @State private var userName: String = "Neznámý uživatel"
    @State private var userEmail: String = "Nepřihlášeno"
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Color(.systemGray5) // 🎨 Pozadí aplikace
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                BottomSheetView(
                    selectedDetent: $selectedDetent,
                    userName: $userName,
                    userEmail: $userEmail,
                    isLoggedIn: $isLoggedIn
                )
                // 🪄 Zde je teď .height(80) místo zlomku, aby to bylo fakt maličké!
                .presentationDetents([.height(80), .medium, .large], selection: $selectedDetent)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
            }
    }
}

struct BottomSheetView: View {
    @State private var sliderValue: Double = 50
    @State private var toggleValue: Bool = false
    @State private var textValue: String = ""
    @State private var showProfile = false
    
    @Binding var selectedDetent: PresentationDetent
    
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 0) {
            
            // 📌 HLAVIČKA (Vždy viditelná)
            HStack(spacing: 15) {
                // 🎚️ Náš Slider
                Slider(value: $sliderValue, in: 0...100)
                    .tint(.blue)
                
                // 🖼️ Profilovka
                Button(action: {
                    showProfile.toggle()
                }) {
                    Image(systemName: isLoggedIn ? "person.crop.circle.fill" : "person.crop.circle.badge.questionmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(isLoggedIn ? .blue : .gray)
                }
            }
            .padding(.horizontal)
            // 📏 Přesně spočítaný padding, aby se to hezky vešlo do height(80)
            .padding(.top, 20) 
            .padding(.bottom, 20)
            // ❌ Bílé pozadí JE PRYČ! 👻
            
            // 🙈 ZOBRAZÍ SE POUZE KDYŽ JE PANEL ROZBALENÝ (Větší než 80)
            if selectedDetent != .height(80) {
                
                // ➖ Oddělovací linka se objeví až po rozbalení
                Divider()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // 🟢 Přepínač (Toggle)
                        Toggle("Zapnout super funkci ✨", isOn: $toggleValue)
                            .font(.body)
                            .padding(.top, 15)
                        
                        // ✍️ Textové pole
                        TextField("Napiš něco sem...", text: $textValue)
                            .padding()
                            .background(.ultraThinMaterial) 
                            .cornerRadius(10)
                        
                        // 🔘 Tlačítko používající TVŮJ .glass styl! 🧊
                        Button(action: {
                            print("Skleněné tlačítko funguje! 🎉")
                        }) {
                            Text("Klikni na mě! 🚀")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding() 
                        }
                        .buttonStyle(.glass) // 👈 Skleněný GitHub styl! 💎
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Spacer() // Vyplní zbytek, když je panel dole
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent) // 🌸 Ještě plynulejší animace
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .presentationDetents([.medium])
        }
    }
}

// 👤 Okno Profilu a Přihlášení
struct ProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoggedIn {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.blue)
                    .padding(.top, 30)

                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                Button(action: {
                    isLoggedIn = false
                    userName = "Neznámý uživatel"
                    userEmail = "Nepřihlášeno"
                }) {
                    Text("Odhlásit se 🚪")
                        .foregroundColor(.red)
                        .padding(.top, 15)
                }
            } else {
                Image(systemName: "applelogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.top, 40)
                
                Text("Přihlášení")
                    .font(.title)
                    .fontWeight(.bold)
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let firstName = appleIDCredential.fullName?.givenName ?? "🦆 Quacky"
                            let lastName = appleIDCredential.fullName?.familyName ?? "🎮"
                            let email = appleIDCredential.email ?? "quacky@apple.com"
                            
                            self.userName = "\(firstName) \(lastName)"
                            self.userEmail = email
                            self.isLoggedIn = true
                        }
                    case .failure(let error):
                        print("Chyba při přihlášení: \(error.localizedDescription) ❌")
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // 🧪 NOUZOVÉ TLAČÍTKO PRO TESTOVÁNÍ NA GITHUB ACTIONS 
                Button(action: {
                    self.userName = "🦆 Quacky 🎮"
                    self.userEmail = "quacky@test.com"
                    self.isLoggedIn = true
                }) {
                    Text("Testovací přihlášení (Bypass) 🧪")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            Spacer()
        }
    }
}
