import SwiftUI
import UIKit

@main
struct SwiftyAppApp: App {
    @AppStorage("useNewStyle") private var useNewStyle: Bool = true
    
    init() {
        // Přečtení nastavení při startu
        let isNewStyle = UserDefaults.standard.bool(forKey: "useNewStyle")
        
        if isNewStyle {
            // Nový styl: Obnovení výchozího iOS vzhledu
            UINavigationBar.appearance().standardAppearance = UINavigationBarAppearance()
            UINavigationBar.appearance().scrollEdgeAppearance = nil
            UINavigationBar.appearance().compactAppearance = nil
            
            UITabBar.appearance().standardAppearance = UITabBarAppearance()
            UITabBar.appearance().scrollEdgeAppearance = nil
        } else {
            // Starý styl: Neprůhledný vzhled
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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
