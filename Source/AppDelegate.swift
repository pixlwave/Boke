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
    
    func applicationWillTerminate(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
}
