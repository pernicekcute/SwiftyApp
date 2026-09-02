import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useOldStyle: Bool) {
    if useOldStyle {
        // 🧱 OLD STYLE
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

    } else {
        // 🌟 SYSTEM STYLE
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

    static func parseBool(from content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            // Přeskočit prázdné řádky a komentáře
            if trimmedLine.isEmpty ||
                trimmedLine.hasPrefix("#") ||
                trimmedLine.hasPrefix("//") {
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
        let timestamp = Date().timeIntervalSince1970

        let urlString =
            "https://raw.githubusercontent.com/pernicekcute/SwiftyApp/refs/heads/main/iosstyle.txt?nocache=\(timestamp)"

        if let url = URL(string: urlString),
           let content = try? String(contentsOf: url, encoding: .utf8) {

            let useOldStyle = ThemeManager.parseBool(from: content)

            ThemeManager.configureTheme(
                useOldStyle: useOldStyle
            )

        } else {
            // Pokud se config nepodaří načíst,
            // použije se starý styl.
            ThemeManager.configureTheme(
                useOldStyle: true
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock =
        UIInterfaceOrientationMask.portrait

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}