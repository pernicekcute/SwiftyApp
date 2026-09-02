import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useNewStyle: Bool) {
        if useNewStyle {
            // Nový / moderní vzhled (starý kód je vynechaný)
            UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
            UINavigationBar.appearance().scrollEdgeAppearance = nil
            UINavigationBar.appearance().compactAppearance = nil
            
            UITabBar.appearance().standardAppearance = UITabBarAppearance()
            UITabBar.appearance().scrollEdgeAppearance = nil
        } else {
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
        }
    }
    
    static func fetchRemoteStyle() {
        guard let url = URL(string: "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let content = String(data: data, encoding: .utf8) else { return }
            
            let isTrue = content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
            
            DispatchQueue.main.async {
                configureTheme(useNewStyle: isTrue)
            }
        }
        task.resume()
    }
}

@main
struct SwiftyAppApp: App {
    
    init() {
        // Synchronní pokus o načtení textu z remote URL
        if let url = URL(string: "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            let isTrue = content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
            ThemeManager.configureTheme(useNewStyle: isTrue)
        } else {
            // Výchozí starý styl, pokud se soubor nenačte
            ThemeManager.configureTheme(useNewStyle: false)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// AppDelegate pro zamknutí orientace na výšku
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
