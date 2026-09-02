import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useOldStyle: Bool) {
        if useOldStyle {
            // 🧱 Starý neprůhledný vzhled (iOS 14 a starší styl)
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = .systemBackground
        } else {
            // 🌟 SKUTEČNÝ VÝCHOZÍ iOS STYL (Průhledné okraje, blur až při scrollování) 🌟
            
            // --- Navigation Bar (Nahoře) ---
            let standardNav = UINavigationBarAppearance()
            standardNav.configureWithDefaultBackground() // Blur efekt při posunu
            
            let transparentNav = UINavigationBarAppearance()
            transparentNav.configureWithTransparentBackground() // Zcela průhledné na začátku
            
            UINavigationBar.appearance().standardAppearance = standardNav
            UINavigationBar.appearance().scrollEdgeAppearance = transparentNav
            UINavigationBar.appearance().compactAppearance = standardNav

            // --- Tab Bar (Dole) ---
            let standardTab = UITabBarAppearance()
            standardTab.configureWithDefaultBackground() // Blur efekt při posunu
            
            let transparentTab = UITabBarAppearance()
            transparentTab.configureWithTransparentBackground() // Zcela průhledné, když obsah nedosahuje až sem
            
            UITabBar.appearance().standardAppearance = standardTab
            UITabBar.appearance().scrollEdgeAppearance = transparentTab
            
            // Výchozí Alerts
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = nil
        }
    }
    
    static func parseBool(from content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Přeskočení prázdných řádků a komentářů
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") || trimmedLine.hasPrefix("//") {
                continue
            }
            
            return trimmedLine.lowercased() == "true"
        }
        
        return false 
    }
}

@main
struct SwiftyAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Obcházení cache pomocí časového razítka v URL
        let timestamp = Date().timeIntervalSince1970
        let urlString = "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt?nocache=\(timestamp)"
        
        if let url = URL(string: urlString),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            let useOldStyle = ThemeManager.parseBool(from: content)
            ThemeManager.configureTheme(useOldStyle: useOldStyle)
        } else {
            // Výchozí starý styl v případě selhání sítě
            ThemeManager.configureTheme(useOldStyle: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// AppDelegate pro zamykání orientace displeje
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
