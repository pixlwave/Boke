import Foundation

class Engine {
    
    static let client = Engine()
    
    var timer: Timer?
    
    var maxTimeAwake = TimeInterval(3600)
    var updateFrequency = TimeInterval(60)
    
    var bootDate: Date? { return Sysctl.date(for: "kern.boottime") }
    var wakeDate: Date? { return Sysctl.date(for: "kern.waketime") }
    var screenSleepDate: Date?
    var screenWakeDate: Date?
    
    private init() {
        // com.apple.screenIsLocked seeems to get posted when the screen sleeps irrespective of whether it actually locks.
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(stop), name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(start), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
        
        timer = newTimer()
    }
    
    
    @objc func start() {
        guard timer == nil else { return }
        timer = newTimer()
    }
    
    @objc func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func timeAwake() -> TimeInterval {
        var dates = [Date]()
        
        if let bootDate = bootDate { dates.append(bootDate) }
        if let wakeDate = wakeDate { dates.append(wakeDate) }
        
        dates.sort()
        
        guard let mostRecentDate = dates.last else { fatalError("Unable to read times!")}
        return Date().timeIntervalSince(mostRecentDate)
    }
    
    func timeRemaining() -> TimeInterval {
        return maxTimeAwake - timeAwake()
    }
    
    func update() {
        let time = timeAwake()
        
        if time > maxTimeAwake {
            let notification = NSUserNotification()
            notification.title = "Take a break!"
            notification.informativeText = "You've been working for \(time.formatted ?? "too long") without a break"
            notification.soundName = nil
            notification.hasActionButton = false
            NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            NSUserNotificationCenter.default.deliver(notification)
        } else {
            NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        }
    }
    
    func newTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { _ in
            self.update()
        }
    }

}


// MARK: Sysctl Additions
extension Sysctl {
    
    public static func date(for string: String) -> Date? {
        guard let keys = try? Sysctl.keys(for: string) else { return nil }
        return Sysctl.date(for: keys)
    }
    
    public static func date(for keys: [Int32]) -> Date? {
        guard let result = try? Sysctl.data(for: keys) else { return nil }
        
        var seconds = 0
        let data = NSData(bytes: result, length: 8)
        data.getBytes(&seconds, length: 8)
        let date = Date(timeIntervalSince1970: Double(seconds))
        return date
    }
    
}
