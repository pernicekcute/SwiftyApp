import SwiftUI
import UIKit

@main
struct SwiftyAppApp: App {
    
    init() {
        // 1. Klasický neprůhledný vzhled pro Navigation Bar (horní lišta)
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        navAppearance.compactAppearance = navAppearance

        // 2. Klasický neprůhledný vzhled pro Tab Bar (dolní lišta)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // 3. Vypnutí průhlednosti a skleněných efektů u systémových oken a prvků
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = .systemBackground
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


// AppDelegate to globally enforce portrait mode
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
