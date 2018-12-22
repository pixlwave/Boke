import Foundation

extension Formatter {
    
    static let timeInterval: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
}

extension TimeInterval {
    
    var formatted: String? {
        return Formatter.timeInterval.string(from: self)
    }
    
}
