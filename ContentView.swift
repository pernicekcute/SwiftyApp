import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var showSheet = true
    
    @State private var userName: String = "Neznámý uživatel"
    @State private var userEmail: String = "Nepřihlášeno"
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Color(.systemGray5)
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                BottomSheetView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                    .presentationDetents([.fraction(0.20), .medium, .large]) // Mírně zvětšeno pro lepší zobrazení hlavičky
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
    
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 0) {
            
            // 📌 UZAMČENÁ HLAVIČKA (Vždy nahoře)
            VStack(spacing: 15) {
                
                // Hledáček / Slider a Profilovka
                HStack(spacing: 15) {
                    // 🎚️ Náš Slider místo vyhledávací lišty
                    Slider(value: $sliderValue, in: 0...100)
                        .tint(.blue)
                    
                    // 🖼️ Profilovka uzamčená vpravo nahoře
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
                
                // 🟢 Přepínač (Toggle) uzamčený hned pod profilovkou
                Toggle("Zapnout super funkci ✨", isOn: $toggleValue)
                    .font(.body)
                    .padding(.bottom, 5)
            }
            .padding(.horizontal)
            .padding(.top, 25) // Mezera od horní hrany sheetu
            .padding(.bottom, 15)
            .background(Color(UIColor.systemBackground)) // Plné pozadí, aby přes hlavičku neprosvítal text ze ScrollView
            
            // ➖ Oddělovací linka (jako v Apple Mapách)
            Divider()
            
            // 📜 SCROLLOVACÍ OBSAH (Tady bude všechno ostatní)
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ✍️ Textové pole
                    TextField("Napiš něco sem...", text: $textValue)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.top, 15)
                    
                    // 🔘 Tlačítko
                    Button(action: {
                        print("Tlačítko bylo stisknuto! 🎉")
                    }) {
                        Text("Klikni na mě! 🚀")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                    // Tady můžeš přidávat další a další obsah a vše bude pěkně scrollovat 
                    // dolů, zatímco hlavička zůstane uzamčená nahoře! 🧱
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .presentationDetents([.medium])
        }
    }
}

// 👤 Okno Profilu a Přihlášení (Zůstává stejné)
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
                
                Text("Pro zobrazení profilu se přihlas pomocí svého Apple ID. 🍎")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let firstName = appleIDCredential.fullName?.givenName ?? "Skvělý"
                            let lastName = appleIDCredential.fullName?.familyName ?? "Uživatel"
                            let email = appleIDCredential.email ?? "Skrytý e-mail 🕵️‍♂️"
                            
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
            }
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
