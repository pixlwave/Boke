import Foundation

class System {
    
    static var maxTimeAwake = TimeInterval(3600)
    static var updateFrequency = TimeInterval(60)
    
    static var bootDate: Date? { return Sysctl.date(for: "kern.boottime") }
    static var wakeDate: Date? { return Sysctl.date(for: "kern.waketime") }
    static var screenWakeDate: Date?
    
    static func timeAwake() -> TimeInterval {
        var dates = [Date]()
        
        if let bootDate = System.bootDate { dates.append(bootDate) }
        if let wakeDate = System.wakeDate { dates.append(wakeDate) }
        
        dates.sort()
        
        guard let mostRecentDate = dates.last else { fatalError("Unable to read times!")}
        return Date().timeIntervalSince(mostRecentDate)
    }
    
    static func timeRemaining() -> TimeInterval {
        return maxTimeAwake - timeAwake()
    }
    
    static func update() {
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
    
    static func newTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { _ in
            System.update()
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
