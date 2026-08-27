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
        // Mapování hardwaru na procesory 🍎🗺️
switch identifier {
    
// MARK: - 🧠 Řada A (iPhone, iPad, Apple TV, iPod)
    
// ⚙️ A7
case "iPhone6,1", "iPhone6,2", // iPhone 5s
     "iPad4,1", "iPad4,2", "iPad4,3", // iPad Air
     "iPad4,4", "iPad4,5", "iPad4,6", // iPad mini 2
     "iPad4,7", "iPad4,8", "iPad4,9": // iPad mini 3
    return "A7"

// ⚙️ A8 & A8X
case "iPhone7,1", "iPhone7,2", // iPhone 6 Plus, iPhone 6
     "iPad5,1", "iPad5,2", // iPad mini 4
     "iPod7,1", // iPod touch (6th gen)
     "AppleTV5,3": // Apple TV HD
    return "A8"
case "iPad5,3", "iPad5,4": // iPad Air 2
    return "A8X"

// ⚙️ A9 & A9X
case "iPhone8,1", "iPhone8,2", // iPhone 6s, 6s Plus
     "iPhone8,4", // iPhone SE (1st gen)
     "iPad6,11", "iPad6,12": // iPad (5th gen)
    return "A9"
case "iPad6,3", "iPad6,4", // iPad Pro (9.7-inch)
     "iPad6,7", "iPad6,8": // iPad Pro (12.9-inch 1st gen)
    return "A9X"

// ⚙️ A10 & A10X Fusion
case "iPhone9,1", "iPhone9,2", "iPhone9,3", "iPhone9,4", // iPhone 7, 7 Plus
     "iPad7,5", "iPad7,6", // iPad (6th gen)
     "iPad7,11", "iPad7,12", // iPad (7th gen)
     "iPod9,1": // iPod touch (7th gen)
    return "A10 Fusion"
case "iPad7,1", "iPad7,2", // iPad Pro (12.9-inch 2nd gen)
     "iPad7,3", "iPad7,4", // iPad Pro (10.5-inch)
     "AppleTV6,2": // Apple TV 4K (1st gen)
    return "A10X Fusion"

// ⚙️ A11 Bionic
case "iPhone10,1", "iPhone10,4", // iPhone 8
     "iPhone10,2", "iPhone10,5", // iPhone 8 Plus
     "iPhone10,3", "iPhone10,6": // iPhone X
    return "A11 Bionic"

// ⚙️ A12, A12X & A12Z Bionic
case "iPhone11,2", // iPhone XS
     "iPhone11,4", "iPhone11,6", // iPhone XS Max
     "iPhone11,8", // iPhone XR
     "iPad11,1", "iPad11,2", // iPad mini (5th gen)
     "iPad11,3", "iPad11,4", // iPad Air (3rd gen)
     "iPad11,6", "iPad11,7", // iPad (8th gen)
     "AppleTV11,1": // Apple TV 4K (2nd gen)
    return "A12 Bionic"
case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4", // iPad Pro (11-inch 1st gen)
     "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": // iPad Pro (12.9-inch 3rd gen)
    return "A12X Bionic"
case "iPad8,9", "iPad8,10", // iPad Pro (11-inch 2nd gen)
     "iPad8,11", "iPad8,12": // iPad Pro (12.9-inch 4th gen)
    return "A12Z Bionic"

// ⚙️ A13 Bionic
case "iPhone12,1", // iPhone 11
     "iPhone12,3", // iPhone 11 Pro
     "iPhone12,5", // iPhone 11 Pro Max
     "iPhone12,8", // iPhone SE (2nd gen)
     "iPad12,1", "iPad12,2": // iPad (9th gen)
    return "A13 Bionic"

// ⚙️ A14 Bionic
case "iPhone13,1", // iPhone 12 mini
     "iPhone13,2", // iPhone 12
     "iPhone13,3", // iPhone 12 Pro
     "iPhone13,4", // iPhone 12 Pro Max
     "iPad13,1", "iPad13,2", // iPad Air (4th gen)
     "iPad13,16", "iPad13,17": // iPad (10th gen)
    return "A14 Bionic"

// ⚙️ A15 Bionic (Včetně tvého iPhone 13 mini! 🤍✨)
case "iPhone14,2", // iPhone 13 Pro
     "iPhone14,3", // iPhone 13 Pro Max
     "iPhone14,4", // iPhone 13 mini 🦆📱
     "iPhone14,5", // iPhone 13
     "iPhone14,6", // iPhone SE (3rd gen)
     "iPhone14,7", // iPhone 14
     "iPhone14,8", // iPhone 14 Plus
     "iPad14,1", "iPad14,2", // iPad mini (6th gen)
     "AppleTV14,1": // Apple TV 4K (3rd gen)
    return "A15 Bionic"

// ⚙️ A16 Bionic
case "iPhone15,2", // iPhone 14 Pro
     "iPhone15,3", // iPhone 14 Pro Max
     "iPhone15,4", // iPhone 15
     "iPhone15,5": // iPhone 15 Plus
    return "A16 Bionic"

// ⚙️ A17 Pro
case "iPhone16,1", // iPhone 15 Pro
     "iPhone16,2": // iPhone 15 Pro Max
    return "A17 Pro"


// MARK: - 💻 Řada M (Apple Silicon pro iPad a Mac)

// ⚡ M1
case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", // iPad Pro (11-inch 3rd gen)
     "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", // iPad Pro (12.9-inch 5th gen)
     "iPad13,18", "iPad13,19", // iPad Air (5th gen)
     "MacBookAir10,1", "Macmini9,1", "MacBookPro17,1", "iMac21,1", "iMac21,2":
    return "M1"

// ⚡ M2
case "iPad14,3", "iPad14,4", // iPad Pro (11-inch 4th gen)
     "iPad14,5", "iPad14,6", // iPad Pro (12.9-inch 6th gen)
     "iPad14,8", "iPad14,9", // iPad Air (11-inch M2)
     "iPad14,10", "iPad14,11", // iPad Air (13-inch M2)
     "Mac14,2", "Mac14,3", "Mac14,7": // Základní M2 Macy
    return "M2"
    
// ⚡ M3
case "Mac15,3", "Mac15,4", "Mac15,5", "Mac15,12", "Mac15,13": // Různé M3 Macy (Air, iMac, MBP)
    return "M3"

// ⚡ M4
case "iPad16,3", "iPad16,4", // iPad Pro (11-inch M4)
     "iPad16,5", "iPad16,6": // iPad Pro (13-inch M4)
    return "M4"

// 🤷‍♂️ Fallback pro budoucí modely (např. beta buildy iOS 18/27 nebo neznámé simulátory)
case "i386", "x86_64", "arm64": 
    return "iOS Simulator 🖥️"
default: 
    return "Unknown Apple Silicon 🍏"
}

    }
}
