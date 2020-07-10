import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let system = System.client
    let network = Network.client
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var preferencesWindow: NSWindowController?
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var proxyMenuItem: NSMenuItem!
    @IBOutlet weak var firewallMenuItem: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.image = #imageLiteral(resourceName: "MenuBarUnknown")
        statusItem.menu = menu
        
        menu.delegate = self
        NSUserNotificationCenter.default.delegate = self
        
        updateMenu()
        
        if network.ssids.count > 0 {
            menu.items.insert(NSMenuItem.separator(), at: 3)
            
            for ssid in network.ssids.reversed() {
                let item = NSMenuItem(title: "Connect to \(ssid)", action: #selector(connectToNetwork(_:)), keyEquivalent: "")
                item.representedObject = ssid
                menu.items.insert(item, at: 3)
            }
        }
    }
    
    @IBAction func toggleProxy(_ sender: Any) {
        network.toggleProxy()
        updateMenu()
    }
    
    @IBAction func toggleFirewall(_ sender: Any) {
        network.toggleFirewall()
        updateMenu()
    }
    
    @IBAction func connectToNetwork(_ sender: Any) {
        guard let item = sender as? NSMenuItem, let ssid = item.representedObject as? String else { return }
        network.connect(to: ssid)
    }
    
    func updateMenu() {
        switch (network.proxyEnabled, network.firewallEnabled) {
        case (false, false):
            statusItem.button?.image = #imageLiteral(resourceName: "MenubarIcon")
            proxyMenuItem.title = "Enable Proxy"
            firewallMenuItem.title = "Enable Firewall"
        case (true, false):
            statusItem.button?.image = #imageLiteral(resourceName: "MenuBarProxy")
            proxyMenuItem.title = "Disable Proxy"
            firewallMenuItem.title = "Enable Firewall"
        case (false, true):
            statusItem.button?.image = #imageLiteral(resourceName: "MenuBarFirewall")
            proxyMenuItem.title = "Enable Proxy"
            firewallMenuItem.title = "Disable Firewall"
        case (true, true):
            statusItem.button?.image = #imageLiteral(resourceName: "MenuBarProxyFirewall")
            proxyMenuItem.title = "Disable Proxy"
            firewallMenuItem.title = "Disable Firewall"
        }
    }
    
    @IBAction func showPreferencesWindow(_ sender: Any) {
        if preferencesWindow == nil {
            preferencesWindow = storyboard.instantiateController(withIdentifier: "PreferencesWindow") as? NSWindowController
            preferencesWindow?.window?.contentView = PreferencesView.makeHostedView()
        }
        
        preferencesWindow?.showWindow(self)
        NSApplication.shared.arrangeInFront(self)
    }
    
    #warning("Add a call to this")
    func preferencesWindowDidClose() {
        preferencesWindow = nil
    }
    
}


// MARK: NSMenuDelegate
extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        let timeRemaining = system.timeRemaining()
        
        if timeRemaining > 0 {
            timeRemainingMenuItem.title = "\(timeRemaining.formatted ?? "Some time") remaining"
        } else {
            timeRemainingMenuItem.title = "\(abs(timeRemaining).formatted ?? "Some time") over"
        }
    }
}


// MARK: NSUserNotificationCenterDelegate
extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
