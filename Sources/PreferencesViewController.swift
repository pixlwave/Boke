import Cocoa

class PreferencesViewController: NSViewController {
    
    let system = System.client
    let network = Network.client
    
    @IBOutlet weak var workTimeSlider: NSSlider!
    @IBOutlet weak var workTimeLabel: NSTextField!
    @IBOutlet weak var resetTimeSlider: NSSlider!
    @IBOutlet weak var resetTimeLabel: NSTextField!
    @IBOutlet weak var notificationFrequencyControl: NSSegmentedControl!
    
    @IBOutlet weak var soundsCheckbox: NSButton!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var networkTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workTimeSlider.doubleValue = system.alertTime / 300
        workTimeLabel.stringValue = system.alertTime.formatted ?? ""
        resetTimeSlider.doubleValue = system.resetTime / 60
        resetTimeLabel.stringValue = system.resetTime.formatted ?? ""
        notificationFrequencyControl.selectSegment(withTag: system.notificationFrequency)
        
        soundsCheckbox.state = system.makesSound ? .on : .off
        
        statusLabel.stringValue =
            """
            Boot date: \(system.bootDate?.description ?? "nil")
            Wake date: \(system.wakeDate?.description ?? "nil")
            Unlock date: \(system.screenWakeDate?.description ?? "nil")
            Time awake: \(system.timeAwake().formatted ?? "Error")
            """
    }
    
    override func viewDidDisappear() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.preferencesWindowDidClose()
    }
    
    @IBAction func workTimeChanged(_ sender: NSSlider) {
        system.alertTime = sender.doubleValue.rounded() * 300
        workTimeLabel.stringValue = system.alertTime.formatted ?? ""
    }
    
    @IBAction func resetTimeChanged(_ sender: NSSlider) {
        let time = sender.doubleValue * 60
        system.resetTime = time.rounded()
        resetTimeLabel.stringValue = system.resetTime.formatted ?? ""
    }
    
    @IBAction func notificationFrequencyChanged(_ sender: NSSegmentedControl) {
        system.notificationFrequency = sender.tag(forSegment: sender.selectedSegment)
    }
    
    @IBAction func toggleSounds(_ sender: NSButton) {
        system.makesSound = sender.state == .on
    }
    
    @IBAction func addNetwork(_ sender: Any) {
        let alert = NSAlert()
        alert.informativeText = "Please enter the name for the new network"
        alert.messageText = "Network Name"
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        
        let ssidNameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 20))
        alert.accessoryView = ssidNameTextField
        
        if alert.runModal() == .alertFirstButtonReturn, !ssidNameTextField.stringValue.isEmpty {
            network.ssids.append(ssidNameTextField.stringValue)
            networkTableView.reloadData()
        }
    }
    
    @IBAction func removeSelectedNetwork(_ sender: Any) {
        if networkTableView.selectedRow >= 0 {
            network.ssids.remove(at: networkTableView.selectedRow)
            networkTableView.reloadData()
        }
    }
    
}


extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        network.ssids.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        network.ssids[row]
    }
}
