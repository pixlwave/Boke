import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var timer: Timer!
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var preferencesWindow: NSWindowController?
    
    @IBOutlet weak var menu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.image = #imageLiteral(resourceName: "MenubarIcon")
        statusItem.button?.image?.isTemplate = true
        statusItem.menu = menu
        
        menu.delegate = self
        NSUserNotificationCenter.default.delegate = self
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            System.update()
        }
    }
    
    @IBAction func showPreferencesWindow(_ sender: Any) {
        if preferencesWindow == nil {
            preferencesWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PreferencesWindow")) as? NSWindowController
        }
        
        preferencesWindow?.showWindow(self)
        NSApplication.shared.arrangeInFront(self)
    }
    
}


// MARK: NSMenuDelegate
extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        let timeRemaining = System.timeRemaining()
        
        if timeRemaining > 0 {
            menu.item(at: 0)?.title = "\(timeRemaining.formatted ?? "Some time") remaining"
        } else {
            menu.item(at: 0)?.title = "Time's up!"
        }
    }
    
}


// MARK: NSUserNotificationCenterDelegate
extension AppDelegate: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
}
