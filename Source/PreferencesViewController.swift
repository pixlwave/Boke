import Cocoa

class PreferencesViewController: NSViewController {
    
    let engine = Engine.client
    
    @IBOutlet weak var workTimeSlider: NSSlider!
    @IBOutlet weak var workTimeLabel: NSTextField!
    @IBOutlet weak var resetTimeSlider: NSSlider!
    @IBOutlet weak var resetTimeLabel: NSTextField!
    
    @IBOutlet weak var soundsCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workTimeSlider.doubleValue = engine.maxTimeAwake / 60
        workTimeLabel.stringValue = engine.maxTimeAwake.formatted ?? ""
        resetTimeSlider.doubleValue = engine.screenSleepResetTime / 60
        resetTimeLabel.stringValue = engine.screenSleepResetTime.formatted ?? ""
        
    }
    @IBAction func workTimeChanged(_ sender: NSSlider) {
        let time = sender.doubleValue * 60
        engine.maxTimeAwake = time.rounded()
        workTimeLabel.stringValue = engine.maxTimeAwake.formatted ?? ""
    }
    
    @IBAction func resetTimeChanged(_ sender: NSSlider) {
        let time = sender.doubleValue * 60
        engine.screenSleepResetTime = time.rounded()
        resetTimeLabel.stringValue = engine.screenSleepResetTime.formatted ?? ""
    }
    
    @IBAction func toggleSounds(_ sender: NSButton) {
        //
    }
    
}

