import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useOldStyle: Bool) {
        if useOldStyle {
            // Starý neprůhledný vzhled
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
            // Nový výchozí styl
            UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
            UINavigationBar.appearance().scrollEdgeAppearance = nil
            UINavigationBar.appearance().compactAppearance = nil
            
            UITabBar.appearance().standardAppearance = UITabBarAppearance()
            UITabBar.appearance().scrollEdgeAppearance = nil
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
        // Synchronní načtení konfiguračního souboru při startu
        if let url = URL(string: "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt"),
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
