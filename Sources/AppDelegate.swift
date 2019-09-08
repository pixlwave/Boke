import Cocoa
import AppUpdater

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let updater = AppUpdater(owner: "pixlwave", repo: "Boke")
    
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
        updater.allowPrereleases = true
        
        statusItem.button?.image = #imageLiteral(resourceName: "MenuBarUnknown")
        statusItem.menu = menu
        
        menu.delegate = self
        NSUserNotificationCenter.default.delegate = self
        
        updateMenu()
    }
    
    @IBAction func toggleProxy(_ sender: Any) {
        network.toggleProxy()
        updateMenu()
    }
    
    @IBAction func toggleFirewall(_ sender: Any) {
        network.toggleFirewall()
        updateMenu()
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
            preferencesWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PreferencesWindow")) as? NSWindowController
        }
        
        preferencesWindow?.showWindow(self)
        NSApplication.shared.arrangeInFront(self)
    }
    
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
