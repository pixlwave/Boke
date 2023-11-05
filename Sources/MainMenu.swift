import SwiftUI

struct MainMenu: Scene {
    private let system = System.client
    private let network = Network.client
    private let inputMapper = InputMapper.shared
    
    var body: some Scene {
        MenuBarExtra {
            Button(proxyItemTitle, action: Network.client.toggleProxy)
            Button(firewallItemTitle, action: Network.client.toggleFirewall)
            
            Divider()
            
            Text(timeRemaining)
            #warning("Dates don't update in the MenuBar?")
            // Text(system.alertDate, style: .timer)
            
            SettingsLink()
            Button("Quit", action: quit)
        } label: {
            // Use a label with an NSImage as the image parameter doesn't render as Retina.
            Label { Text("Boke") } icon: { Image(nsImage: .init(resource: icon)) }
        }
    }
    
    var icon: ImageResource {
        switch (network.proxyEnabled, network.firewallEnabled) {
        case (false, false):
            return .menuBarIcon
        case (true, false):
            return .menuBarProxy
        case (false, true):
            return .menuBarFirewall
        case (true, true):
            return .menuBarProxyFirewall
        }
    }
    
    var proxyItemTitle: String {
        network.proxyEnabled ? "Disable Proxy" : "Enable Proxy"
    }
    
    var firewallItemTitle: String {
        network.firewallEnabled ? "Disable Firewall" : "Enable Firewall"
    }
    
    var timeRemaining: String {
        let timeRemaining = system.timeRemaining
        
        if timeRemaining > 0 {
            return "\(timeRemaining.formatted ?? "Some time") remaining"
        } else {
            return "\(abs(timeRemaining).formatted ?? "Some time") over"
        }
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
}
