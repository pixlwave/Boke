import Cocoa

class Network {
    
    static let client = Network()
    
    var proxyEnabled = false
    var firewallEnabled = false
    
    var ssids = UserDefaults.standard.object(forKey: "ssids") as? [String] ?? [String]() {
        didSet { UserDefaults.standard.set(ssids, forKey: "ssids") }
    }
    
    private init() {
        updateProxyState()
        updateFirewallState()
    }
    
    func toggleProxy() {
        if proxyEnabled {
            Process.launch("/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "off"])
        } else {
            Process.launch("/usr/sbin/networksetup", arguments: ["-setsocksfirewallproxystate", "Wi-Fi", "on"])
        }
        
        updateProxyState()
    }
    
    func updateProxyState() {
        let path = "/usr/sbin/networksetup"
        let arguments = ["-getsocksfirewallproxy", "Wi-Fi"]

        if let result = Process.launch(returning: path, arguments: arguments) {
            // get first line with 'Enabled: Yes' and then read after 'Enabled: '
            proxyEnabled = result.components(separatedBy: "\n")[0].components(separatedBy: ": ")[1] == "Yes"
        }
    }

    func toggleFirewall() {
        // sudo ./socketfilterfw --setblockall on
        // sudo ./socketfilterfw --setblockall off
        
        if firewallEnabled {
            Process.launch("/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off\" with administrator privileges"])
        } else {
            Process.launch("/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on\" with administrator privileges"])
        }
        
        updateFirewallState()
    }
    
    func updateFirewallState() {
        let path = "/usr/libexec/ApplicationFirewall/socketfilterfw"
        let arguments = ["--getblockall"]
        
        if let result = Process.launch(returning: path, arguments: arguments) {
            // check if the result includes the word 'DISABLED!'
            firewallEnabled = !result.contains("DISABLED!")
        }
    }
    
    func connect(to networkName: String) {
        let path = "/usr/sbin/networksetup"
        let arguments = ["-setairportnetwork", "en0", networkName]
        
        Process.launch(path, arguments: arguments)
    }
    
}
