import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var proxyMenuItem: NSMenuItem!
    @IBOutlet weak var firewallMenuItem: NSMenuItem!
    
    var proxyEnabled = false
    var firewallEnabled = false
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2.0)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: "unknown")
        statusItem.highlightMode = true
        statusItem.menu = statusMenu
        
        updateProxyState()
        updateFirewallState()
    }
    
    @IBAction func toggleProxy(_ sender: NSMenuItem) {
        if proxyEnabled {
            launch(process: "/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "off"])
        } else {
            launch(process: "/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "on"])
        }
        
        updateProxyState()
    }
    
    func updateProxyState() {
        let path = "/usr/sbin/networksetup"
        let arguments = ["-getsocksfirewallproxy", "Wi-Fi"]

        if let result = launch(returningProcess: path, arguments: arguments) {
            // get first line with 'Enabled: Yes' and then read after 'Enabled: '
            if result.components(separatedBy: "\n")[0].components(separatedBy: ": ")[1] == "Yes" {
                proxyEnabled = true
                proxyMenuItem.title = "Disable Proxy"
            } else {
                proxyEnabled = false
                proxyMenuItem.title = "Enable Proxy"
            }
        }
        
        updateIcon()
    }

    @IBAction func toggleFirewall(_ sender: NSMenuItem) {
        // sudo ./socketfilterfw --setblockall on
        // sudo ./socketfilterfw --setblockall off
        
        if firewallEnabled {
            launch(process: "/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off\" with administrator privileges"])
        } else {
            launch(process: "/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on\" with administrator privileges"])
        }
        
        updateFirewallState()
    }
    
    func updateFirewallState() {
        let path = "/usr/libexec/ApplicationFirewall/socketfilterfw"
        let arguments = ["--getblockall"]
        
        if let result = launch(returningProcess: path, arguments: arguments) {
            // check if the result include the word 'DISABLED!'
            if (result as NSString).contains("DISABLED!") {
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
    
    func launch(process path: String, arguments: [String]) {
        let process = Process()
        process.launchPath = path
        process.arguments = arguments
        
        process.launch()
        process.waitUntilExit()
    }
    
    func launch(returningProcess path: String, arguments: [String]) -> String? {
        let process = Process()
        process.launchPath = path
        process.arguments = arguments
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        process.launch()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)
        
        return outputString as? String
    }

    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
}

