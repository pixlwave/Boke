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
        let path = "/usr/sbin/networksetup"
        let arguments = ["-setsocksfirewallproxystate", "Wi-Fi"]
        
        if proxyEnabled {
            Process.launch(path, with: arguments + ["off"])
        } else {
            Process.launch(path, with: arguments + ["on"])
        }
        
        updateProxyState()
    }
    
    func updateProxyState() {
        let path = "/usr/sbin/networksetup"
        let arguments = ["-getsocksfirewallproxy", "Wi-Fi"]

        if let result = Process.launch(returning: path, with: arguments) {
            // get first line with 'Enabled: Yes' and then read after 'Enabled: '
            proxyEnabled = result.components(separatedBy: "\n")[0].components(separatedBy: ": ")[1] == "Yes"
        }
    }

    func toggleFirewall() {
        let path = "/usr/bin/osascript"
        let arguments = ["-e"]
        
        if firewallEnabled {
            // sudo ./socketfilterfw --setblockall on
            let script = "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off\" with administrator privileges"
            Process.launch(path, with: arguments + [script])
        } else {
            // sudo ./socketfilterfw --setblockall off
            let script = "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on\" with administrator privileges"
            Process.launch(path, with: arguments + [script])
        }
        
        updateFirewallState()
    }
    
    func updateFirewallState() {
        let path = "/usr/libexec/ApplicationFirewall/socketfilterfw"
        let arguments = ["--getblockall"]
        
        if let result = Process.launch(returning: path, with: arguments) {
            // check if the result includes the word 'DISABLED!'
            firewallEnabled = !result.contains("DISABLED!")
        }
    }
    
    func connect(to networkName: String) {
        let path = "/usr/sbin/networksetup"
        let arguments = ["-setairportnetwork", "en0", networkName]
        
        Process.launch(path, with: arguments)
    }
    
}
