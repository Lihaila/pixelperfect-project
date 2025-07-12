import SwiftUI

@main
struct PixelPerfect_iOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NavigationManager())
        }
    }
}
