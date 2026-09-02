import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useOldStyle: Bool) {
        if useOldStyle {
            // 🧱 Starý neprůhledný vzhled 🧱
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
            // 🌟 Nový moderní iOS 27 skleněný (translucent) vzhled 🌟
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithDefaultBackground() // Vytvoří ten hezký blur efekt! ✨
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithDefaultBackground()
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            
            // Vrátí Alertům jejich přirozený systémový iOS 27 vzhled 🎨
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = nil
        }
    }
    
    static func parseBool(from content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Přeskočení prázdných řádků a komentářů 🛑📝
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") || trimmedLine.hasPrefix("//") {
                continue
            }
            
            return trimmedLine.lowercased() == "true"
        }
        
        return false // Pokud tam není "true", hodí false a zapne iOS 27 styl! 😎
    }
}

@main
struct SwiftyAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // 🚀 Obcházení cache pomocí časového razítka v URL, ať se změny projeví hned! 🚀
        let timestamp = Date().timeIntervalSince1970
        let urlString = "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt?nocache=\(timestamp)"
        
        if let url = URL(string: urlString),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            let useOldStyle = ThemeManager.parseBool(from: content)
            ThemeManager.configureTheme(useOldStyle: useOldStyle)
        } else {
            // 📡 Výchozí starý styl v případě selhání sítě (když není internet) 📡
            ThemeManager.configureTheme(useOldStyle: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// 🔄 AppDelegate pro zamykání orientace displeje na výšku 🔄
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
