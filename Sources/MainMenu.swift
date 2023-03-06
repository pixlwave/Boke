import SwiftUI

struct MainMenu: Scene {
    @ObservedObject private var system = System.client
    @ObservedObject private var network = Network.client
    @ObservedObject private var inputMapper = InputMapper.shared
    
    var body: some Scene {
        MenuBarExtra("Boke", image: icon) {
            Button(proxyItemTitle, action: Network.client.toggleProxy)
            Button(firewallItemTitle, action: Network.client.toggleFirewall)
            
            Divider()
            
            Text(timeRemaining) // TODO: Use a Date with a formatter so this updates.
            
            Button("Settings…", action: showSettings)
            Button("Quit", action: quit)
        }
    }
    
    var icon: String {
        switch (network.proxyEnabled, network.firewallEnabled) {
        case (false, false):
            return "MenuBarIcon"
        case (true, false):
            return "MenuBarProxy"
        case (false, true):
            return "MenuBarFirewall"
        case (true, true):
            return "MenuBarProxyFirewall"
        }
    }
    
    var proxyItemTitle: String {
        network.proxyEnabled ? "Disable Proxy" : "Enable Proxy"
    }
    
    var firewallItemTitle: String {
        network.firewallEnabled ? "Disable Firewall" : "Enable Firewall"
    }
    
    var timeRemaining: String {
        let timeRemaining = System.client.timeRemaining()
        
        if timeRemaining > 0 {
            return "\(timeRemaining.formatted ?? "Some time") remaining"
        } else {
            return "\(abs(timeRemaining).formatted ?? "Some time") over"
        }
    }
    
    func showSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
}
