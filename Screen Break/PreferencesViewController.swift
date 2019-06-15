import Cocoa

class PreferencesViewController: NSViewController {
    
    let engine = Engine.shared

    @IBOutlet weak var workSessionLengthSlider: NSSlider!
    @IBOutlet weak var workSessionLengthLabel: NSTextField!
    @IBOutlet weak var breakLengthSlider: NSSlider!
    @IBOutlet weak var breakLengthLabel: NSTextField!
    
    @IBOutlet weak var elapsedWorkTimeLabel: NSTextField!
    @IBOutlet weak var elapsedIdleTimeLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine.delegate = self
        
        workSessionLengthSlider.integerValue = engine.workSessionLength / 60
        workSessionLengthLabel.stringValue = "\(workSessionLengthSlider.integerValue) minutes"
        breakLengthSlider.integerValue = engine.breakLength / 60
        breakLengthLabel.stringValue = "\(breakLengthSlider.integerValue) minutes"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        engine.updateRegularly()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.updateInBackground()
    }
    
    @IBAction func changeWorkTime(_ sender: Any) {
        if let slider = sender as? NSSlider, slider == workSessionLengthSlider {
            engine.workSessionLength = slider.integerValue * 60
            workSessionLengthLabel.stringValue = "\(slider.integerValue) minutes"
        }
    }
    
    @IBAction func changeBreakTime(_ sender: Any) {
        if let slider = sender as? NSSlider, slider == breakLengthSlider {
            engine.breakLength = slider.integerValue * 60
            breakLengthLabel.stringValue = "\(slider.integerValue) minutes"
        }
    }
    
}

extension PreferencesViewController: EngineDelegate {
    
    func engineUpdated() {
        elapsedWorkTimeLabel.integerValue = engine.timeSpentWorking
        elapsedIdleTimeLabel.integerValue = engine.elapsedIdleTime
    }
    
}
