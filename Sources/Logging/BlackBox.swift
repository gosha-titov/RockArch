import Foundation

/// The black box that handles all incoming messages by passing them to its loggers.
open class RABlackBox: RAAnyObject {
    
    /// The black box that is currently in use.
    ///
    /// You can set your own black box to redirect log messages.
    /// By default, the current black box is `.console`.
    public static var current: RABlackBox = .console
    
    /// The default black box that uses the console logger.
    public static let console: RABlackBox = {
        let consoleLogger = RAConsoleLogger()
        return RABlackBox(name: "Console", loggers: [consoleLogger])
    }()
    
    /// The default black box that uses the os logger.
    public static let os: RABlackBox = {
        let osLogger = RAOSLogger()
        return RABlackBox(name: "OS", loggers: [osLogger])
    }()
    
    /// The default serial queue in which logging performs.
    ///
    /// The queue has the `.background` quality-of-service.
    public static let queue = DispatchQueue(label: "com.rockarch.blackbox-builtin", qos: .background)
    
    /// A string associated with the name of this black box.
    public let name: String
    
    /// A textual representation of the type of this black box.
    ///
    /// This property has the "BlackBox" value.
    public let type = "BlackBox"
    
    /// Loggers that receive all messages from this black box.
    public let loggers: [RALogger]
    
    /// The queue in which logging performs.
    public let queue: DispatchQueue
    
    /// Logs a specific message by passing it to its loggers.
    public final func log(_ message: String, author: String, category: String, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        queue.async {
            let info = RAInfo(fileID: fileID, function: function, line: line)
            let message = RALogMessage(author: author, text: message, category: category, level: level, info: info)
            for logger in self.loggers where logger.thresholdLogLevel <= level {
                logger.log(message)
            }
        }
    }
    
    /// Creates a black box instance with specific loggers that will log messages in the given queue.
    /// - Parameter name: The string associated with the name of this black box.
    /// - Parameter loggers: Loggers that will receive all messages coming into this black box.
    /// - Parameter queue: The queue in which logging will be performed.
    /// To keep the correct order of messages, pass a serial queue.
    /// The default value is `RABlackBox.queue`.
    public init(name: String, loggers: [RALogger], queue: DispatchQueue = RABlackBox.queue) {
        self.loggers = loggers
        self.queue = queue
        self.name = name
    }
    
}
