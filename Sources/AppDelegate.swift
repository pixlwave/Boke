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
        
        statusItem.button?.image = #imageLiteral(resourceName: "MenubarIcon")
        statusItem.button?.image?.isTemplate = true
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
        if network.proxyEnabled {
            if network.firewallEnabled {
                statusItem.button?.image = #imageLiteral(resourceName: "prfw")
                proxyMenuItem.title = "Disable Proxy"
                firewallMenuItem.title = "Disable Firewall"
            } else {
                statusItem.button?.image = #imageLiteral(resourceName: "pr")
                proxyMenuItem.title = "Disable Proxy"
                firewallMenuItem.title = "Enable Firewall"
            }
        } else {
            if network.firewallEnabled {
                statusItem.button?.image = #imageLiteral(resourceName: "fw")
                proxyMenuItem.title = "Enable Proxy"
                firewallMenuItem.title = "Disable Firewall"
            } else {
                statusItem.button?.image = #imageLiteral(resourceName: "off")
                proxyMenuItem.title = "Enable Proxy"
                firewallMenuItem.title = "Enable Firewall"
            }
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
