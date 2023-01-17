import Foundation

/// The black box that records all incoming messages by passing them to its loggers.
open class RABlackBox {
    
    // MARK: - Static
    
    /// The black box that is currently in use.
    public static var current: RABlackBox = .default
    
    /// The black box that uses os and console loggers.
    public static let `default`: RABlackBox = {
        let consoleLogger = RAConsoleLogger()
        let osLogger = RAOSLogger()
        let queue = DispatchQueue(label: "blackbox-default", qos: .background)
        return RABlackBox(loggers: [consoleLogger, osLogger], queue: queue)
    }()
    
    /// Passes this message to the loggers of the current black box.
    ///
    /// You usually don't use this log method directly:
    ///
    ///     RABlackBox.log(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: "Network",
    ///         level: .error
    ///     )
    ///
    /// Instead, you call the static method corresponding to a log level of your message:
    ///
    ///     RABlackBox.error(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: "Network"
    ///     )
    ///
    /// - Parameter message:  A string to log.
    /// - Parameter author:   A string that describes an author of this message.
    /// - Parameter category: A string that describes a category of this message.
    /// - Parameter level:    A level associated how important this message is.
    public static func log(_ message: String, author: String, category: String, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        current.log(message, author: author, category: category, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    /// Passes this message to the loggers of the current black box.
    ///
    /// You usually don't use this log method directly:
    ///
    ///     RABlackBox.log(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: .network,
    ///         level: .error
    ///     )
    ///
    /// Instead, you call the static method corresponding to a log level of your message:
    ///
    ///     RABlackBox.error(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: .network
    ///     )
    ///
    /// - Parameter message:  A string to log.
    /// - Parameter author:   A string that describes an author of this message.
    /// - Parameter category: A category of this message.
    /// - Parameter level:    A level associated how important this message is.
    public static func log(_ message: String, author: String, category: RALogCategory, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        current.log(message, author: author, category: category.rawValue, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    
    // MARK: - Public Properties
    
    /// Loggers that receive all messages from this black box.
    public let loggers: [RALogger]
    
    /// The queue in which logging performs.
    public let queue: DispatchQueue
    
    
    // MARK: - Public Methods
    
    /// Logs a specific message by passing it to its loggers.
    public final func log(_ message: String, author: String, category: String, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        queue.async {
            let info = RAInfo(fileID: fileID, function: function, line: line)
            let message = RALogMessage(author: author, text: message, category: category, level: level, info: info)
            for logger in self.loggers {
                logger.log(message)
            }
        }
    }
    
    
    // MARK: - Public Init
    
    /// Creates a black box with specific loggers that will log messages in this queue.
    /// - Parameter loggers: Loggers that will receive all messages coming into this black box.
    /// - Parameter queue: A queue in which logging will be performed. To keep the correct order of messages, pass a serial queue.
    public init(loggers: [RALogger], queue: DispatchQueue = .init(label: "blackbox-custom", qos: .background)) {
        self.loggers = loggers
        self.queue = queue
    }
    
}

extension RABlackBox {
    
    public static func trace(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    public static func trace(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    
    public static func debug(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .debug, fileID: fileID, function: function, line: line)
    }
    
    public static func debug(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .debug, fileID: fileID, function: function, line: line)
    }
    
    
    public static func info(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .info, fileID: fileID, function: function, line: line)
    }
    
    public static func info(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .info, fileID: fileID, function: function, line: line)
    }
    
    
    public static func warning(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .warning, fileID: fileID, function: function, line: line)
    }
    
    public static func warning(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .warning, fileID: fileID, function: function, line: line)
    }
    
    
    public static func error(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .error, fileID: fileID, function: function, line: line)
    }
    
    public static func error(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .error, fileID: fileID, function: function, line: line)
    }
    
    
    public static func fatal(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .fatal, fileID: fileID, function: function, line: line)
    }
    
    public static func fatal(_ message: String, author: String, category: RALogCategory, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .fatal, fileID: fileID, function: function, line: line)
    }
    
}
