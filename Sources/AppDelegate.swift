import Cocoa
import AppUpdater

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let updater = AppUpdater(owner: "pixlwave", repo: "Boke")
    
    var engine = Engine.client
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var preferencesWindow: NSWindowController?
    
    @IBOutlet weak var menu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updater.allowPrereleases = true
        
        statusItem.button?.image = #imageLiteral(resourceName: "MenubarIcon")
        statusItem.button?.image?.isTemplate = true
        statusItem.menu = menu
        
        menu.delegate = self
        NSUserNotificationCenter.default.delegate = self
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
        let timeRemaining = engine.timeRemaining()
        
        if timeRemaining > 0 {
            menu.item(at: 0)?.title = "\(timeRemaining.formatted ?? "Some time") remaining"
        } else {
            menu.item(at: 0)?.title = "\(abs(timeRemaining).formatted ?? "Some time") over"
        }
    }
    
}


// MARK: NSUserNotificationCenterDelegate
extension AppDelegate: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
}
