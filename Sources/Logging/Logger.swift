import Foundation
import os

/// The default logger that prints messages to the console.
///
/// You don't interact with this logger directly. You use it as one of the parameters for a black box.
/// The default black box uses this logger.
///
/// The console logger prints incoming messages in the following way:
///
///     "[Network] 8:39:52 PM <error> Weather-Service: No internet connection."
///      category  timestamp   level      author                text
///
/// You can set a threshold log level to not receive lower-level messages from a black box.
/// By default, the threshold level is `.trace`.
public struct RAConsoleLogger: RALogger {
    
    /// A string associated with the name of this logger.
    ///
    /// This property has the "Console" value.
    public let name = "Console"
    
    /// The threshold log level that restricts the flow of incoming log messages from a black box.
    ///
    /// By changing the value of this property, you do not receive lower-level messages.
    /// By default, the threshold level is `.trace`.
    public var thresholdLogLevel: RALogLevel = .trace
    
    /// Logs a specific message by printing it to the console.
    public func log(_ message: RALogMessage) -> Void {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let time = formatter.string(from: message.timestamp)
        let category = message.category.isEmpty ? "Unspecified" : message.category
        let author   = message.author.isEmpty   ? "Unspecified" : message.author
        let level = message.level.rawValue
        let text = message.text
        print("[\(category)] \(time) <\(level)> \(author): \(text).")
    }
    
    /// Creates a console logger instance.
    public init() {}
    
}



/// The os logger that sends messages to the logging system.
///
/// You don't interact with this logger directly. You use it as one of the parameters for the black box.
/// The default black box uses this logger.
///
/// The os logger logs incoming messages in the following way:
///
///     """
///     Category  |  Time                  |  Type  |  Subsystem        |  Message
///     ––––––––––+––––––––––––––––––––––––+––––––––+–––––––––––––––––––+––––––––––––––––––––––––
///     Network      20:39:52.257992+0300      🟡      Weather-Service     No internet connection
///     """
///
/// You can set a threshold log level to not receive lower-level messages from a black box.
/// By default, the threshold level is `.info`.
public struct RAOSLogger: RALogger {
    
    /// A string associated with the name of this logger.
    ///
    /// This property has the "OS" value.
    public let name = "OS"
    
    /// The threshold log level that restricts the flow of incoming log messages from a black box.
    ///
    /// By changing the value of this property, you do not receive lower-level messages.
    /// By default, the threshold level is `.info`.
    public var thresholdLogLevel: RALogLevel = .info
    
    /// Logs a specific message by sending it to the logging system.
    public func log(_ message: RALogMessage) -> Void {
        let log = OSLog(subsystem: message.author, category: message.category)
        let logType = message.level.toOSLogType
        let message = message.text
        os_log(logType, log: log, "%{public}@", message)
    }
    
    /// Creates an os logger instance.
    public init() {}
    
}



/// A type that can log messages in a simplified way.
///
/// The `RALoggable` protocol simplifies the logging process by specifying this object as an author of a message.
/// That is, you call the `log(_:category:level:)` method instead of calling the corresponding log method of the black box.
/// For example, calling this:
///
///     log("No internet connection", category: "Network", level: .error)
///
/// does the same thing as:
///
///     RABlackBox.error(
///         "No internet connection",
///         author: "Weather-Service",
///         category: "Network"
///     )
///
/// As a result, the following message will be printed:
///
///     "[Network] 7:26:33 PM <error> Weather-Service: No internet connection."
///
/// All key objects conform to the `RALoggable` protocol.
public protocol RALoggable where Self: RAObject {
    
    /// Logs a message by specifying this object as an author.
    ///
    /// Call this method when you need to log a message on behalf of this object. For example:
    ///
    ///     log("No internet connection", category: "Network", level: .error)
    ///
    /// As a result, the following message will be printed:
    ///
    ///     "[Network] 7:26:33 PM <error> Weather-Service: No internet connection."
    ///
    /// - Parameter message:  The text to log.
    /// - Parameter category: The string that describes a category of this message.
    /// - Parameter level:    The level with which this message will be logged.
    func log(_ message: String, category: String, level: RALogLevel, fileID: String, function: String, line: Int) -> Void
    
}

public extension RALoggable {
    
    func log(_ message: String, category: String, level: RALogLevel = .debug, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        RABlackBox.log(message, author: description, category: category, level: level, fileID: fileID, function: function, line: line)
    }
    
}



/// A type that can log messages.
///
/// The central function of the logger is to handle incoming log messages.
/// You usually use the logger in a black box that passes messages to it.
///
/// There are built-in console and os loggers, see `RAConsoleLogger` and `RAOSLogger`.
/// But if you need to customize the printing of log messages or redirect them then you define a new struct that conforms to the `RALogger` protocol.
///
/// By setting a threshold log level, you do not receive lower-level messages from a black box.
/// That is, you don't need to compare the level of the incoming log message and this threshold level.
/// By default, the threshold level is `.trace`.
public protocol RALogger: RAObject {
    
    /// The threshold log level that restricts the flow of incoming log messages from a black box.
    var thresholdLogLevel: RALogLevel { get }
    
    /// Logs a specific message.
    func log(_ message: RALogMessage) -> Void
    
}

public extension RALogger {
    
    /// The threshold log level that restricts the flow of incoming log messages from a black box.
    ///
    /// It's the default implementation of this property, so the threshold level is `.trace`.
    var thresholdLogLevel: RALogLevel {
        return .trace
    }
    
    /// A textual representation of the type of this logger.
    ///
    /// It's the default implementation of this property, so the type has the "Logger" value.
    var type: String {
        return "Logger"
    }
    
}
