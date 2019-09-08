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

extension Process {
    static func launch(_ path: String, with arguments: [String]) {
        let process = Process()
        process.launchPath = path
        process.arguments = arguments
        
        process.launch()
        process.waitUntilExit()
    }
    
    static func launch(returning path: String, with arguments: [String]) -> String? {
        let process = Process()
        process.launchPath = path
        process.arguments = arguments
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        process.launch()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)
        
        return outputString as String?
    }
}
