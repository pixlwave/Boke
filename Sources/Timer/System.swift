import UserNotifications

class System: ObservableObject {
    static let client = System()
    
    var timer: Timer?
    var updateFrequency = TimeInterval(60)
    
    @Published var alertTime = UserDefaults.standard.object(forKey: "alertTime") as? Double ?? TimeInterval(3600) {
        didSet { UserDefaults.standard.set(alertTime, forKey: "alertTime") }
    }
    @Published var resetTime = UserDefaults.standard.object(forKey: "resetTime") as? Double ?? TimeInterval(120) {
        didSet { UserDefaults.standard.set(resetTime, forKey: "resetTime") }
    }
    @Published var notificationFrequency = UserDefaults.standard.object(forKey: "notificationFrequency") as? Int ?? 5 {
        didSet { UserDefaults.standard.set(notificationFrequency, forKey: "notificationFrequency") }
    }
    @Published var makesSound = UserDefaults.standard.object(forKey: "makesSound") as? Bool ?? false {
        didSet { UserDefaults.standard.set(makesSound, forKey: "makesSound") }
    }
    
    var bootDate: Date? { return Sysctl.date(for: "kern.boottime") }
    var wakeDate: Date? { return Sysctl.date(for: "kern.waketime") }
    var screenSleepDate: Date?
    var screenWakeDate: Date?
    
    private init() {
        // com.apple.screenIsLocked seeems to get posted when the screen sleeps irrespective of whether it actually locks.
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(screenDidSleep),
                                                            name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(screenDidWake),
                                                            name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
        
        timer = makeTimer()
        
        update()    // remove stale notifications
    }
    
    @objc func screenDidSleep() {
        timer?.invalidate()
        timer = nil
        
        screenSleepDate = Date()
    }
    
    @objc func screenDidWake() {
        if timer == nil { timer = makeTimer() }
        
        if let screenSleepDate = screenSleepDate {
            let now = Date()
            let screenSleepTime = now.timeIntervalSince(screenSleepDate)
            if screenSleepTime > resetTime {
                screenWakeDate = now
                removeAllNotifications()
            }
            self.screenSleepDate = nil
        }
    }
    
    func timeAwake() -> TimeInterval {
        var dates = [Date]()
        
        if let bootDate = bootDate { dates.append(bootDate) }
        if let wakeDate = wakeDate { dates.append(wakeDate) }
        if let screenWakeDate = screenWakeDate { dates.append(screenWakeDate) }
        
        dates.sort()
        
        guard let mostRecentDate = dates.last else { fatalError("Unable to read times!")}
        return Date().timeIntervalSince(mostRecentDate)
    }
    
    func timeRemaining() -> TimeInterval {
        alertTime - timeAwake()
    }
    
    func update() {
        let time = timeAwake()
        
        if time > alertTime {
            let minutesPast = Int((time - alertTime) / 60)
            if minutesPast % notificationFrequency == 0 {
                deliverNotification(for: time)
            }
        } else {
            removeAllNotifications()
        }
    }
    
    func deliverNotification(for time: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = time.formatted ?? "ERROR"
        content.subtitle = "of screen time"
        content.sound = makesSound ? .default : nil
        let request = UNNotificationRequest(identifier: "timer", content: content, trigger: nil)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func makeTimer() -> Timer {
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
