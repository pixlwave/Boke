import AppKit
import Carbon.HIToolbox
import Combine

@Observable class InputMapper: NSObject {
    static var shared: InputMapper = InputMapper()
    
    private(set) var jitsi = ControllableApp(processIdentifier: nil) {
        $0.bundleIdentifier == "org.jitsi.jitsi-meet"
    }
    private(set) var elementCall = ControllableApp(processIdentifier: nil) {
        $0.bundleIdentifier?.starts(with: "com.apple.Safari.WebApp") == true && $0.localizedName == "Element Call"
    }
    private(set) var lastMidi: UInt8?
    
    private var cancellables = [AnyCancellable]()
    
    let midi = MIDIManager()
    
    let keymap: [UInt8: Command] = [
        36: ModifiedKeyCommand(key: kVK_ANSI_C),    // reaction - clap
        37: KeyCommand(key: kVK_ANSI_V),            // toggle video
        38: KeyCommand(key: kVK_ANSI_M),            // toggle mic
        39: MomentaryKeyCommand(key: kVK_Space),    // push to talk
        
        40: ModifiedKeyCommand(key: kVK_ANSI_L),    // reaction - laugh
        41: KeyCommand(key: kVK_ANSI_D),            // screen sharing
        42: KeyCommand(key: kVK_ANSI_F),            // toggle thumbnails
        43: KeyCommand(key: kVK_ANSI_W),            // tile view
        
        44: ModifiedKeyCommand(key: kVK_ANSI_T),    // reaction - thumbs up
        45: ModifiedKeyCommand(key: kVK_ANSI_O),    // reaction - surprised
        46: KeyCommand(key: kVK_ANSI_R),            // raise hand
        47: ModifiedKeyCommand(key: kVK_ANSI_Q,     // end call (quit)
                               modifierFlags: .maskCommand),
        
        48: OpenURLCommand(defaultsKey: "f1URL"),   // function 1
        49: OpenURLCommand(defaultsKey: "f2URL"),   // function 2
        50: OpenURLCommand(defaultsKey: "f3URL"),   // function 3
        51: SpecialKeyCommand()                     // special
    ]
    
    var tickTimer: AnyCancellable?
    
    private override init() {
        super.init()
        
        midi.delegate = self
        
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .sink(receiveValue: didLaunchApplication(notification:))
            .store(in: &cancellables)
        
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)
            .sink(receiveValue: didTerminateApplication(notification:))
            .store(in: &cancellables)
        
        // A timer to refresh the LEDs in case an app launches whilst the keybow is disconnected
        tickTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.jitsi.processIdentifier != nil {
                    self.midi.keybowStart()
                } else if self.elementCall.processIdentifier != nil {
                    self.midi.keybowContinue()
                }
            }
    }
    
    func didLaunchApplication(notification: Notification) {
        guard let app = application(from: notification) else { return }
        
        if jitsi.matchesRunningApplication(app) {
            jitsi.processIdentifier = app.processIdentifier
            midi.keybowStart()  // light up the keybow's leds
        } else if elementCall.matchesRunningApplication(app) && jitsi.processIdentifier == nil {
            elementCall.processIdentifier = app.processIdentifier
            midi.keybowContinue()   // light up the keybow's leds
        }
    }
    
    func didTerminateApplication(notification: Notification) {
        guard let app = application(from: notification) else { return }
        
        if jitsi.matchesRunningApplication(app) {
            jitsi.processIdentifier = nil
            
            if elementCall.processIdentifier != nil {
                midi.keybowContinue()   // switch to the element call layout
            } else {
                midi.keybowStop()   // turn off the keybow's leds
            }
        } else if elementCall.matchesRunningApplication(app) {
            elementCall.processIdentifier = nil
            
            if jitsi.processIdentifier == nil {
                midi.keybowStop()   // turn off the keybow's leds
            }
        }
    }
    
    func application(from notification: Notification) -> NSRunningApplication? {
        notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    }
}


// MARK: - MidiDelegate
extension InputMapper: MIDIDelegate {
    func midi(note: UInt8, isOn: Bool) {
        DispatchQueue.main.async { if isOn { self.lastMidi = note } }
        
        guard let command = keymap[note] else { return }
        
        command.run(keyDown: isOn, for: jitsi.processIdentifier ?? elementCall.processIdentifier)
    }
}
