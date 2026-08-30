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
            
            // 📌 HLAVIČKA (Vždy viditelná) - Perfektně vycentrovaná vertikálně! 🎯
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
            
            // 🙈 ZOBRAZÍ SE POUZE KDYŽ JE PANEL ROZBALENÝ (Větší než 80)
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
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent) // 🌸 Plynulá animace
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .presentationDetents([.medium])
        }
    }
}
