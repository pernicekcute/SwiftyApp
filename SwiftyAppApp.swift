import SwiftUI
import UIKit

class ThemeManager {
    static func applyTheme(useNewStyle: Bool) {
        if useNewStyle {
            // Obnovení nového/systémového vzhledu
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithDefaultBackground()
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithDefaultBackground()
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = nil
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
}

@main
struct SwiftyAppApp: App {
    @AppStorage("useNewStyle") private var useNewStyle: Bool = true

    init() {
        let isNewStyle = UserDefaults.standard.bool(forKey: "useNewStyle")
        ThemeManager.applyTheme(useNewStyle: isNewStyle)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
