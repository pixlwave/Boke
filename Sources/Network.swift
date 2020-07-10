import Foundation

class Network: ObservableObject {
    
    static let client = Network()
    
    var proxyEnabled = false
    var firewallEnabled = false
    
    @Published var ssids = UserDefaults.standard.object(forKey: "ssids") as? [String] ?? [String]() {
        didSet { UserDefaults.standard.set(ssids, forKey: "ssids") }
    }
    
    private init() {
        updateProxyState()
        updateFirewallState()
    }
    
    func toggleProxy() {
        let path = "/usr/sbin/networksetup"
        let value = proxyEnabled ? "off" : "on"
        let arguments = ["-setsocksfirewallproxystate", "Wi-Fi", value]
        
        Process.launch(path, with: arguments + [value])
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
        let value = firewallEnabled ? "off" : "on"
        let arguments = [
            // sudo ./socketfilterfw --setblockall on
            // sudo ./socketfilterfw --setblockall off
            "-e", "do shell script \"/usr/libexec/ApplicationFirewall/socketfilterfw --setblockall \(value)\" with administrator privileges"
        ]
        
        Process.launch(path, with: arguments)
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
