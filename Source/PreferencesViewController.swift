import Cocoa

class PreferencesViewController: NSViewController {
    
    let engine = Engine.client
    
    @IBOutlet weak var workTimeSlider: NSSlider!
    @IBOutlet weak var workTimeLabel: NSTextField!
    @IBOutlet weak var resetTimeSlider: NSSlider!
    @IBOutlet weak var resetTimeLabel: NSTextField!
    @IBOutlet weak var notificationFrequencyControl: NSSegmentedControl!
    
    @IBOutlet weak var soundsCheckbox: NSButton!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workTimeSlider.doubleValue = engine.alertTime / 300
        workTimeLabel.stringValue = engine.alertTime.formatted ?? ""
        resetTimeSlider.doubleValue = engine.resetTime / 60
        resetTimeLabel.stringValue = engine.resetTime.formatted ?? ""
        notificationFrequencyControl.selectSegment(withTag: engine.notificationFrequency)
        
        statusLabel.stringValue = """
        Boot date: \(engine.bootDate?.description ?? "nil")
        Wake date: \(engine.wakeDate?.description ?? "nil")
        Unlock date: \(engine.screenWakeDate?.description ?? "nil")
        Time awake: \(engine.timeAwake().formatted ?? "Error")
        """
    }
    
    override func viewDidDisappear() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.preferencesWindowDidClose()
    }
    
    @IBAction func workTimeChanged(_ sender: NSSlider) {
        engine.alertTime = sender.doubleValue.rounded() * 300
        workTimeLabel.stringValue = engine.alertTime.formatted ?? ""
    }
    
    @IBAction func resetTimeChanged(_ sender: NSSlider) {
        let time = sender.doubleValue * 60
        engine.resetTime = time.rounded()
        resetTimeLabel.stringValue = engine.resetTime.formatted ?? ""
    }
    
    @IBAction func notificationFrequencyChanged(_ sender: NSSegmentedControl) {
        engine.notificationFrequency = sender.tag(forSegment: sender.selectedSegment)
    }
    
    @IBAction func toggleSounds(_ sender: NSButton) {
        //
    }
    
}

