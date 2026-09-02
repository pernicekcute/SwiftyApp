import SwiftUI
import UIKit

class ThemeManager {
    static func applyTheme(useiOS26Style: Bool) {
        if useiOS26Style {
            // iOS 26 Style: Průhledný / moderní systémovýzhled
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithDefaultBackground()
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = nil
        } else {
            // Old Style: Klasický neprůhledný blokový vzhled
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
}

@main
struct SwiftyAppApp: App {
    @AppStorage("useiOS26Style") private var useiOS26Style: Bool = true

    init() {
        // Načtení hodnoty z UserDefaults při startu aplikace
        let isNewStyle = UserDefaults.standard.object(forKey: "useiOS26Style") as? Bool ?? true
        ThemeManager.applyTheme(useiOS26Style: isNewStyle)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
