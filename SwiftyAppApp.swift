import SwiftUI
import UIKit

class ThemeManager {
    static func configureTheme(useOldStyle: Bool) {
        if useOldStyle {
            // 🧱 Starý neprůhledný vzhled
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()

            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()

            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance

            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).backgroundColor = .systemBackground

        } else {
            // 🌟 DEFAULTNÍ SYSTÉMOVÝ VZHLED
            // Necháváme iOS, aby si vzhled řídil samo.
            // iOS 27 → iOS 27 styl
            // iOS 28 → iOS 28 styl
            // atd.

            UINavigationBar.appearance().standardAppearance = nil
            UINavigationBar.appearance().scrollEdgeAppearance = nil
            UINavigationBar.appearance().compactAppearance = nil

            UITabBar.appearance().standardAppearance = nil
            UITabBar.appearance().scrollEdgeAppearance = nil

            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).backgroundColor = nil
        }
    }

    static func parseBool(from content: String) -> Bool {
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

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