import Foundation

/// The black box that handles all incoming messages by passing them to its loggers.
///
/// The black box is the main part of logging.
/// It receives all incoming global messages, handles them in its own queue and passing them to its loggers.
///
/// The most basic usage of the black box is to call the static method corresponding to a log level of a message:
///
///     RABlackBox.error(
///         "No internet connection",
///         author: "Weather-Service",
///         category: "Network"
///     )
///
/// If you need to customize the handling of log messages then set a new value for the `current` property:
///
///     RABlackBox.current = {
///         let loggerA = LoggerA()
///         let loggerB = LoggerB()
///         return .init(name: "CustomAB", loggers: [loggerA, loggerB])
///     }()
///
open class RABlackBox: RAAnyObject {
    
    /// The black box that is currently in use.
    ///
    /// You can set your own black box to redirect log messages.
    /// By default, the current black box is `.console`.
    public static var current: RABlackBox = .console
    
    /// The default black box that uses the console logger.
    public static let console: RABlackBox = {
        return .init(name: "Console", loggers: [RAConsoleLogger()])
    }()
    
    /// The default black box that uses the os logger.
    public static let os: RABlackBox = {
        return .init(name: "OS", loggers: [RAOSLogger()])
    }()
    
    /// The default serial queue in which logging performs.
    ///
    /// The queue has the `.background` quality-of-service.
    public static let queue = DispatchQueue(label: "com.rockarch.blackbox-default", qos: .background)
    
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
    
    /// Logs a specific message by passing it to loggers.
    ///
    ///     blackBox.log(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: "Network",
    ///         level: .error
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    /// - Parameter level:    The level associated how important this message is.
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


extension RABlackBox {
    
    /// Logs a specific message by passing it to the current black box.
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
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    /// - Parameter level:    The level associated how important this message is.
    public static func log(_ message: String, author: String, category: String, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        current.log(message, author: author, category: category, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.trace` log level.
    ///
    ///     RABlackBox.trace(
    ///         "Sending a request",
    ///         author: "Auth-Service",
    ///         category: "Server"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func trace(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .trace, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.debug` log level.
    ///
    ///     RABlackBox.debug(
    ///         "User closed the avatar image",
    ///         author: "Avatar-ImageView",
    ///         category: "Profile"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func debug(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .debug, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.info` log level.
    ///
    ///     RABlackBox.info(
    ///         "User gained 94 points out of 100",
    ///         author: "Game-Statistics",
    ///         category: "Game"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func info(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .info, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.warning` log level.
    ///
    ///     RABlackBox.warning(
    ///         "Attemp to add the friend that was already added",
    ///         author: "Friend-CollectionView",
    ///         category: "User"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func warning(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .warning, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.error` log level.
    ///
    ///     RABlackBox.error(
    ///         "No internet connection",
    ///         author: "Weather-Service",
    ///         category: "Network"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func error(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .error, fileID: fileID, function: function, line: line)
    }
    
    /// Logs a specific message by passing it to the current black box and specifying the `.fatal` log level.
    ///
    ///     RABlackBox.fatal(
    ///         "Stop functioning for some reason"
    ///         author: "Image-Editor"
    ///         category: "Library"
    ///     )
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter author:   The string that describes an author of this message.
    /// - Parameter category: The string that describes a category of this message.
    public static func fatal(_ message: String, author: String, category: String, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        log(message, author: author, category: category, level: .fatal, fileID: fileID, function: function, line: line)
    }
    
}
