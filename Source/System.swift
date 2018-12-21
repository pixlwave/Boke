import Foundation

class System {
    
    static var maxTimeAwake = 3600.0
    
    static var screenWakeTime: Date?
    
    public static func bootTime() -> Date? {
        return Sysctl.date(for: "kern.boottime")
    }
    
    public static func wakeTime() -> Date? {
        return Sysctl.date(for: "kern.waketime")
    }
    
    static func update() {
        var times = [Date]()
        
        if let bootTime = System.bootTime() { times.append(bootTime) }
        if let wakeTime = System.wakeTime() { times.append(wakeTime) }
        
        times.sort()
        
        guard let time = times.last else { fatalError("Unable to read times!")}
        let timeAwake = Date().timeIntervalSince(time)
        
        if timeAwake > maxTimeAwake {
            let notification = NSUserNotification()
            notification.title = "Take a break!"
            notification.informativeText = "You've been working for \(Int(timeAwake / 60)) minutes without a break"
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
