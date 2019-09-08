import Cocoa

class PreferencesViewController: NSViewController {
    
    let system = System.client
    
    @IBOutlet weak var workTimeSlider: NSSlider!
    @IBOutlet weak var workTimeLabel: NSTextField!
    @IBOutlet weak var resetTimeSlider: NSSlider!
    @IBOutlet weak var resetTimeLabel: NSTextField!
    @IBOutlet weak var notificationFrequencyControl: NSSegmentedControl!
    
    @IBOutlet weak var soundsCheckbox: NSButton!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
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
    
}

