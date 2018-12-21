import Foundation

class System {
    
    static var maxTimeAwake = TimeInterval(3600)
    
    static var screenWakeTime: Date?
    
    public static func bootTime() -> Date? {
        return Sysctl.date(for: "kern.boottime")
    }
    
    public static func wakeTime() -> Date? {
        return Sysctl.date(for: "kern.waketime")
    }
    
    public static func timeAwake() -> TimeInterval {
        var times = [Date]()
        
        if let bootTime = System.bootTime() { times.append(bootTime) }
        if let wakeTime = System.wakeTime() { times.append(wakeTime) }
        
        times.sort()
        
        guard let time = times.last else { fatalError("Unable to read times!")}
        return Date().timeIntervalSince(time)
    }
    
    public static func timeRemaining() -> TimeInterval {
        return maxTimeAwake - timeAwake()
    }
    
    static func update() {
        let time = timeAwake()
        
        if time > maxTimeAwake {
            let notification = NSUserNotification()
            notification.title = "Take a break!"
            notification.informativeText = "You've been working for \(time.formatted ?? "too long") without a break"
            notification.soundName = NSUserNotificationDefaultSoundName
            notification.hasActionButton = false
            NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            NSUserNotificationCenter.default.deliver(notification)
        } else {
            NSUserNotificationCenter.default.removeAllDeliveredNotifications()
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
