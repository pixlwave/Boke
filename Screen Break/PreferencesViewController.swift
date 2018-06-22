import Cocoa

class PreferencesViewController: NSViewController {
    
    let engine = Engine.shared

    @IBOutlet weak var workTimeSlider: NSSlider!
    @IBOutlet weak var breakTimeSlider: NSSlider!
    
    @IBOutlet weak var workingTimeLabel: NSTextField!
    @IBOutlet weak var idleTimeLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine.delegate = self
        
        workTimeSlider.integerValue = engine.workSessionLength / 60
        breakTimeSlider.integerValue = engine.breakLength / 60
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
        if let slider = sender as? NSSlider, slider == workTimeSlider {
            engine.workSessionLength = slider.integerValue * 60
        }
    }
    
    @IBAction func changeBreakTime(_ sender: Any) {
        if let slider = sender as? NSSlider, slider == breakTimeSlider {
            engine.breakLength = slider.integerValue * 60
        }
    }
    
}

extension PreferencesViewController: EngineDelegate {
    
    func engineUpdated() {
        workingTimeLabel.integerValue = engine.timeSpentWorking
        idleTimeLabel.integerValue = engine.timeSpentIdle
    }
    
}
