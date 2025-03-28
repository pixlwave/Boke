import SwiftUI

@main
struct BokeApp: App {
    var body: some Scene {
        MainMenu()
        
        Settings {
            SettingsView()
        }
        .defaultSize(width: 585, height: 300)
    }
    
    // hide the dock icon
    // NSApplication.shared.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
}
