import SwiftUI

// MARK: - Hlavní pohled aplikace
struct ContentView: View {
    @State private var showSheet = true
    
    // 📏 Nastaveno na výšku 80 pro úvodní lištu se sliderem a profilovkou
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
                .presentationDetents([.height(80), .medium, .large], selection: $selectedDetent)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
            }
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
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 0) {
            
            // 📌 HLAVIČKA (Vždy viditelná) - Perfektně vycentrovaná vertikálně
            if selectedDetent == .height(80) {
                Spacer()
                HStack(alignment: .center, spacing: 15) {
                    Slider(value: $sliderValue, in: 0...100)
                        .tint(.blue)
                    
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
                Spacer()
            } else {
                HStack(alignment: .center, spacing: 15) {
                    Slider(value: $sliderValue, in: 0...100)
                        .tint(.blue)
                    
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
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            // 🙈 ZOBRAZÍ SE POUZE KDYŽ JE PANEL ROZBALENÝ
            if selectedDetent != .height(80) {
                
                // ➖ Oddělovací linka a obsah v závorkách {} 📦
                Divider()
                
                {
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
                            
                            // 🔘 Tlačítko
                            Button(action: {
                                print("Skleněné tlačítko funguje! 🎉")
                            }) {
                                Text("Klikni na mě! 🚀")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding() 
                            }
                            .buttonStyle(.borderedProminent) 
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Profil a standardní přihlášení (E-mail / Heslo)
struct ProfileView: View {
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var isLoggedIn: Bool
    
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var nameInput: String = ""
    @State private var isRegistering: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if isLoggedIn {
                // 🟢 KDYŽ JE UŽIVATEL PŘIHLÁŠENÝ
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
                    emailInput = ""
                    passwordInput = ""
                }) {
                    Text("Odhlásit se 🚪")
                        .foregroundColor(.red)
                        .padding(.top, 15)
                }
            } else {
                // 🔴 KDYŽ JE UŽIVATEL ODHLÁŠENÝ (Formulář)
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text(isRegistering ? "Vytvořit účet ✨" : "Standardní přihlášení 🔑")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    if isRegistering {
                        TextField("Celé jméno", text: $nameInput)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .autocapitalization(.words)
                    }
                    
                    TextField("E-mailová adresa", text: $emailInput)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Heslo", text: $passwordInput)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    if emailInput.isEmpty || passwordInput.isEmpty {
                        errorMessage = "Vyplň prosím všechna pole! ⚠️"
                    } else if isRegistering && nameInput.isEmpty {
                        errorMessage = "Zadej prosím své jméno! ⚠️"
                    } else {
                        errorMessage = ""
                        userName = isRegistering ? nameInput : "Uživatel"
                        userEmail = emailInput
                        isLoggedIn = true
                    }
                }) {
                    Text(isRegistering ? "Zaregistrovat se 🚀" : "Přihlásit se 🔓")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 5)
                
                Button(action: {
                    isRegistering.toggle()
                    errorMessage = ""
                }) {
                    Text(isRegistering ? "Už máš účet? Přihlas se 👈" : "Nemáš účet? Zaregistruj se ✨")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            Spacer()
        }
    }
}
