import UserNotifications

@Observable class System {
    static let client = System()
    
    /// The timer driving all updates.
    var timer: Timer?
    /// How often to recalculate the amount of screen time.
    var updateFrequency = TimeInterval(60)
    
    /// The amount of screen time to allow before triggering the first notification.
    var alertTime = UserDefaults.standard.object(forKey: "alertTime") as? Double ?? TimeInterval(3600) {
        didSet { UserDefaults.standard.set(alertTime, forKey: "alertTime") }
    }
    /// The amount of idle time to wait before resetting the timer.
    var resetTime = UserDefaults.standard.object(forKey: "resetTime") as? Double ?? TimeInterval(120) {
        didSet { UserDefaults.standard.set(resetTime, forKey: "resetTime") }
    }
    /// How regularly notifications should be posted after ``alertTime`` has been exceeded.
    var notificationFrequency = UserDefaults.standard.object(forKey: "notificationFrequency") as? Int ?? 5 {
        didSet { UserDefaults.standard.set(notificationFrequency, forKey: "notificationFrequency") }
    }
    /// Whether or not notifications should be noisy.
    var makesSound = UserDefaults.standard.object(forKey: "makesSound") as? Bool ?? false {
        didSet { UserDefaults.standard.set(makesSound, forKey: "makesSound") }
    }
    
    /// The date at which the system was booted.
    var bootDate: Date? { Sysctl.date(for: "kern.boottime") }
    /// If the system has been to sleep, the date at which the system was woken up.
    var wakeDate: Date? { Sysctl.date(for: "kern.waketime") }
    /// The date at which the screen was last turned off.
    var screenSleepDate: Date?
    /// If the screen has been turned off, the date at which it was turned on again.
    var screenWakeDate: Date?
    
    /// The amount of continuous screen time,
    var timeAwake: TimeInterval { Date.now.timeIntervalSince(startDate) }
    /// The amount of time until a notification should be posted.
    var timeRemaining: TimeInterval { alertTime - timeAwake }
    
    /// The date that should be used to calculate the amount of screen time.
    private var startDate: Date {
        var dates = [Date]()
        
        if let bootDate { dates.append(bootDate) }
        if let wakeDate { dates.append(wakeDate) }
        if let screenWakeDate { dates.append(screenWakeDate) }
        
        dates.sort()
        
        guard let mostRecentDate = dates.last else { fatalError("Unable to read times!") }
        return mostRecentDate
    }
    
    private init() {
        // com.apple.screenIsLocked seems to get posted when the screen sleeps irrespective of whether it actually locks.
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(screenDidSleep),
                                                            name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(screenDidWake),
                                                            name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
        
        timer = makeTimer()
        
        update() // remove stale notifications
    }
    
    @objc func screenDidSleep() {
        timer?.invalidate()
        timer = nil
        
        screenSleepDate = Date.now
    }
    
    @objc func screenDidWake() {
        if timer == nil { timer = makeTimer() }
        
        if let screenSleepDate {
            let now = Date.now
            let screenSleepTime = now.timeIntervalSince(screenSleepDate)
            if screenSleepTime > resetTime {
                screenWakeDate = now
                removeAllNotifications()
            }
            self.screenSleepDate = nil
        }
    }
    
    private func update() {
        let time = timeAwake
        
        if time > alertTime {
            let minutesPast = Int((time - alertTime) / 60)
            if minutesPast % notificationFrequency == 0 {
                deliverNotification(for: time)
            }
        } else {
            removeAllNotifications()
        }
    }
    
    private func deliverNotification(for time: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = time.formatted ?? "ERROR"
        content.subtitle = "of screen time"
        content.sound = makesSound ? .default : nil
        let request = UNNotificationRequest(identifier: "timer", content: content, trigger: nil)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func makeTimer() -> Timer {
        Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { _ in
            self.update()
        }
    }
}


// MARK: Sysctl Additions
private extension Sysctl {
    static func date(for string: String) -> Date? {
        guard let keys = try? Sysctl.keys(for: string) else { return nil }
        return Sysctl.date(for: keys)
    }
    
    static func date(for keys: [Int32]) -> Date? {
        guard let result = try? Sysctl.data(for: keys) else { return nil }
        
        var seconds = 0
        let data = NSData(bytes: result, length: 8)
        data.getBytes(&seconds, length: 8)
        let date = Date(timeIntervalSince1970: Double(seconds))
        return date
    }
}
