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
            
            // 📌 HLAVIČKA - Zde jsou prvky přísně vycentrované na střed vertikálně! 🎯
            HStack(alignment: .center, spacing: 15) {
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
            .padding(.top, 20) 
            .padding(.bottom, 20)
            
            // 🙈 ZOBRAZÍ SE POUZE KDYŽ JE PANEL ROZBALENÝ
            if selectedDetent != .height(80) {
                
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
                        .buttonStyle(.glass)
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Spacer()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDetent)
        .sheet(isPresented: $showProfile) {
            ProfileView(userName: $userName, userEmail: $userEmail, isLoggedIn: $isLoggedIn)
                .presentationDetents([.medium])
        }
    }
}
