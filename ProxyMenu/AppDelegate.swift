import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var proxyMenuItem: NSMenuItem!
    @IBOutlet weak var firewallMenuItem: NSMenuItem!
    
    var proxyEnabled = false
    var firewallEnabled = false
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2.0)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.image = NSImage(named: "unknown")
        statusItem.highlightMode = true
        statusItem.menu = statusMenu
        
        updateProxyState()
        updateFirewallState()
    }
    
    @IBAction func toggleProxy(sender: NSMenuItem) {
        println("toggle")
        if proxyEnabled {
            launchTask("/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "off"])
        } else {
            launchTask("/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "on"])
        }
        
        updateProxyState()
    }
    
    func updateProxyState() {
        println("update")
        let path = "/usr/sbin/networksetup"
        let arguments = ["-getsocksfirewallproxy", "Wi-Fi"]

        if let result = launchReturningTask(path, arguments: arguments) {
            // get first line with 'Enabled: Yes' and then read after 'Enabled: '
            if result.componentsSeparatedByString("\n")[0].componentsSeparatedByString(": ")[1] == "Yes" {
                proxyEnabled = true
                proxyMenuItem.title = "Disable Proxy"
            } else {
                proxyEnabled = false
                proxyMenuItem.title = "Enable Proxy"
            }
        }
        
        updateIcon()
    }

    @IBAction func toggleFirewall(sender: NSMenuItem) {
        // sudo ./socketfilterfw --setblockall on
        // sudo ./socketfilterfw --setblockall off
        
        if firewallEnabled {
            launchTask("/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off\" with administrator privileges"])
        } else {
            launchTask("/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on\" with administrator privileges"])
        }
        
        updateFirewallState()
        println(firewallEnabled)
    }
    
    func updateFirewallState() {
        let path = "/usr/libexec/ApplicationFirewall/socketfilterfw"
        let arguments = ["--getblockall"]
        
        if let result = launchReturningTask(path, arguments: arguments) {
            // check if the result include the word 'DISABLED!'
            if (result as NSString).containsString("DISABLED!") {
                firewallEnabled = false
                firewallMenuItem.title = "Enable Firewall"
            } else {
                firewallEnabled = true
                firewallMenuItem.title = "Disable Firewall"
            }
        }
        
        updateIcon()
    }
    
    func updateIcon() {
        if proxyEnabled {
            if firewallEnabled {
                statusItem.image = NSImage(named: "prfw")
            } else {
                statusItem.image = NSImage(named: "pr")
            }
        } else {
            if firewallEnabled {
                statusItem.image = NSImage(named: "fw")
            } else {
                statusItem.image = NSImage(named: "off")
            }
        }
    }
    
    func launchTask(path: String, arguments: [String]) {
        println(path)
        let task = NSTask()
        task.launchPath = path
        task.arguments = arguments
        
        task.launch()
        task.waitUntilExit()
    }
    
    func launchReturningTask(path: String, arguments: [String]) -> String? {
        let task = NSTask()
        task.launchPath = path
        task.arguments = arguments
        
        let outputPipe = NSPipe()
        task.standardOutput = outputPipe
        
        task.launch()
        task.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = NSString(data: outputData, encoding: NSUTF8StringEncoding)
        
        return outputString as? String
    }

    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}

