import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let engine = Engine.shared
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSApplication.shared.windows.first
        engine.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard flag == false else { return false }
        
        window?.makeKeyAndOrderFront(self)
    
        return false
    }
    
}
