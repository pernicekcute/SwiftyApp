import SwiftUI

struct DeviceStatusWidget: View {
    @State private var isClicked = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isClicked.toggle()
            }
        }) {
            HStack(spacing: 12) {
                // Ikona s dýchající animací a změnou barvy 🔴🫁
                Image(systemName: "iphone")
                    .font(.title2)
                    .foregroundColor(isClicked ? .red : .primary)
                    .symbolEffect(.breathe, options: .repeating, isActive: isClicked)
                
                // Přepínání titulku: Název zařízení vs. Jméno čipu 🏷️🧠
                Text(isClicked ? getChipName() : UIDevice.current.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                // Přepínání trailing textu: Uptime vs. Verze iOS ⏳🔢
                Text(isClicked ? getUptime() : "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle()) // Aby celé pozadí neblikalo při kliknutí 🖱️🚫
    }
    
    // Získání přesného formátovaného času od posledního restartu ⏱️📅
    func getUptime() -> String {
        let uptimeInSeconds = ProcessInfo.processInfo.systemUptime
        let formatter = DateComponentsFormatter()
        
        // Zahrnutí všech požadovaných jednotek (y, m, w, d, h, min, sec) 📆🕰️
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated // Vypíše krátké zkratky
        formatter.maximumUnitCount = 3 // Omezí délku (např. ukáže jen 3 největší dostupné jednotky)
        
        return formatter.string(from: uptimeInSeconds) ?? "Neznámé"
    }
    
    // Získání identifikátoru pro jméno čipu 🛠️⚡
    func getChipName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Mapování hardwaru na procesory 🍎🗺️
        switch identifier {
        case "iPhone14,4", "iPhone14,5": return "A15 Bionic"
        // Sem můžeš přidat další modely podle potřeby! 🏗️
        default: return "Apple Silicon"
        }
    }
}
