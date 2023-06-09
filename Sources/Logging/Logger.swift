import Foundation

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
    /// By default, the threshold level is `.trace`.
    public var thresholdLogLevel: RALogLevel = .trace
    
    /// Logs a specific message by printing it in the console.
    public func log(_ message: RALogMessage) -> Void {
        guard message.text.isEmpty == false else { return }
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
    
    /// The threshold log level that restricts the flow of incoming log messages.
    var thresholdLogLevel: RALogLevel { get }
    
    /// Logs a specific message.
    func log(_ message: RALogMessage) -> Void
    
}

public extension RALogger {
    
    /// The threshold log level that restricts the flow of incoming log messages.
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
