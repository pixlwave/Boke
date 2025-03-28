import AppKit

@MainActor protocol Command {
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


class SpecialKeyCommand: Command {
    private var keyDownTask: Task<Void, Error>?
    private var wasLongPress = false
    
    func run(keyDown: Bool, for processIdentifier: pid_t?) {
        if keyDown {
            guard keyDownTask == nil else { return }
            keyDownTask = Task {
                try await Task.sleep(for: .seconds(0.5))
                didFinishLongPress()
            }
        } else {
            keyDownTask?.cancel()
            keyDownTask = nil
            
            if wasLongPress {
                wasLongPress = false
            } else {
                let elementCall = URL.homeDirectory.appendingPathComponent("Applications/Element Call.app")
                openApp(path: elementCall.path(percentEncoded: false))
            }
        }
    }
    
    private func didFinishLongPress() {
        wasLongPress = true
    }
    
    private func openApp(path: String) {
        open(arguments: [path])
    }
    
    private func openApp(bundleID: String) {
        open(arguments: ["-b", bundleID])
    }
    
    private func open(arguments: [String]) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = arguments
        try? task.run()
        task.waitUntilExit()
    }
}
