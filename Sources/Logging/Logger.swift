/// A type that can log messages.
///
/// The central function of the logger is to handle incoming log messages.
/// You usually use the logger in a black box that passes messages to it.
///
/// There are built-in console and os loggers, see `RAConsoleLogger` and `RAOSLogger`.
/// But if you need to customize the printing of log messages or redirect them then you define a new struct that conforms to the `RALogger` protocol.
///
/// By setting a threshold log level, you do not receive lower-level messages.
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
