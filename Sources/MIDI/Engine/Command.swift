import AppKit

protocol Command {
    /// Runs the command if required based on the parameters
    /// - Parameters:
    ///   - keyDown: Whether the trigger is a key down event.
    ///   - processIdentifier: The currently controlled process ID, `nil` if no applicable processes are running.
    func run(keyDown: Bool, for processIdentifier: pid_t?)
}


struct KeyCommand: Command {
    let key: Int
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        guard let processIdentifier, keyDown else { return }
        
        CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: true)?.postToPid(processIdentifier)
        CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: false)?.postToPid(processIdentifier)
    }
}


struct MomentaryKeyCommand: Command {
    let key: Int
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        guard let processIdentifier else { return }
        if keyDown {
            CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: true)?.postToPid(processIdentifier)
        } else {
            CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: false)?.postToPid(processIdentifier)
        }
    }
}


struct ModifiedKeyCommand: Command {
    let key: Int
    var modifierFlags: CGEventFlags = .maskAlternate
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        guard let processIdentifier, keyDown else { return }
        
        let events = [
            CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: true),
            CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: false),
        ].compactMap { $0 }
        
        events.forEach {
            $0.flags.insert(modifierFlags)
            $0.postToPid(processIdentifier)
        }
    }
}


struct OpenURLCommand: Command {
    let defaultsKey: String
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        guard
            keyDown,
            let url = UserDefaults.standard.url(forKey: defaultsKey)
        else { return }
        
        NSWorkspace.shared.open(url)
    }
}


struct OpenAppCommand: Command {
    let bundleID: String
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        guard keyDown else { return }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-b", bundleID]
        try? task.run()
        task.waitUntilExit()
    }
}

// MARK: - WIP

class SpecialKeyCommand: Command {
    private var keyDownTimer: Timer?
    private var wasLongPress = false
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        DispatchQueue.main.async { [self] in
            if keyDown {
                guard self.keyDownTimer == nil else { return }
                self.keyDownTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.didFinishLongPress), userInfo: nil, repeats: false)
            } else {
                self.keyDownTimer?.invalidate()
                self.keyDownTimer = nil
                
                if self.wasLongPress {
                    self.wasLongPress = false
                } else {
                    self.openApp(bundleID: "org.jitsi.jitsi-meet")
                }
            }
        }
    }
    
    func openApp(bundleID: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-b", bundleID]
        try? task.run()
        task.waitUntilExit()
    }
    
    @objc func didFinishLongPress() {
        wasLongPress = true
        self.openApp(bundleID: "uk.pixlwave.ElementCall")
    }
}
