import Foundation

class Engine {
    static var shared = Engine()
    
    var workSessionLength = 25*60
    var breakLength = 5*60
    var timeSpentWorking = 0
    var elapsedIdleTime = 0
    var lastNotificationDate: Date?
    
    var delegate: EngineDelegate?
    
    private var timer: Timer!
    private var workSessionStartedAt = Date()
    private var notification = NSUserNotification()
    private let notificationCentre = NSUserNotificationCenter.default
    
    private init() {
        notification.title = "Take a break!"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer.tolerance = 0
    }
    
    func updateRegularly() {
        if timer != nil {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            timer.tolerance = 0
        }
    }
    
    func updateInBackground() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer.tolerance = 5
    }
    
    @objc private func update() {
        timeSpentWorking = Int(Date().timeIntervalSince(workSessionStartedAt))
        elapsedIdleTime = Idle().time ?? 0
        
        if elapsedIdleTime < breakLength {   // this will break if nil returned for idleTime
            if timeSpentWorking > workSessionLength {
                guard let interval = lastNotificationDate?.timeIntervalSinceNow, interval > 5 * 60 else { return }
                notification.informativeText = "You've been working for \(timeSpentWorking / 60) minutes without a break"
                notificationCentre.removeAllDeliveredNotifications()
                notificationCentre.deliver(notification)
                lastNotificationDate = Date()
            }
        } else {
            workSessionStartedAt = Date()
        }
        
        delegate?.engineUpdated()
    }
}


// MARK: EngineDelegate
protocol EngineDelegate {
    func engineUpdated()
}
