/// A type that can log messages in a simplified way.
///
/// It allows you not to specify a sender of a log message because the sender is always this object.
public protocol RASimplifiedLoggable {
    
    /// Logs a message in a simplified way by specifying a sender as this object.
    ///
    /// Call this method when you need to log a message on behalf of this object.
    /// For example, if you use a console logger inside the main module:
    ///
    ///     log("something went wrong", as: .error)
    ///     // Prints "[Logger] 10:12:55 PM <error> Main-Module: something went wrong."
    ///
    /// - Parameter message: A string to log.
    /// - Parameter level: A level with which this message will be logged.
    func log(_ message: String, as level: RALogLevel) -> Void
    
}

public extension RASimplifiedLoggable where Self: (RAObject & RALoggerHolder) {
    
    func log(_ message: String, as level: RALogLevel) -> Void {
        logger?.log(message, as: level, from: description)
    }
    
}


/// A type that has a logger.
public protocol RALoggerHolder {
    
    /// A logger that can log messages.
    var logger: RALogger? { get }
    
}


/// A type that can log the messages.
///
/// All key components, such as the modules, interactors, routers, views and builders use a logger that is set for the root module.
/// By default, it's the console logger, but if you need to redirect or customize the printing of log messages,
/// then you define a new class that conforms to the `RALogger` protocol.
public protocol RALogger: RAObject {
    
    /// Logs a message from a specific sender.
    /// - Parameter message: A string to log.
    /// - Parameter level: A level with which this message will be logged.
    /// - Parameter sender: A string that describes a sender of this message.
    func log(_ message: String, as level: RALogLevel, from sender: String) -> Void
    
}

public extension RALogger {
    
    /// A textual representation of the type of this logger.
    var type: String {
        return "Logger"
    }
    
}


/// A level associated how important a log message is.
///
/// There are 6 kinds of log level: trace, debug, info, warning, error and fatal.
public enum RALogLevel: Int, CaseIterable {
    
    /// The most detailed information of all levels that's used in rare cases where you need the full visibility of what happening in your application.
    /// In this case, the logging is very verbose where you see every step of an algorithm, method, etc.
    case trace
    
    /// The fine-grained informational events that are most useful to debug your application.
    /// For daily use, It's more necessary than the trace level.
    case debug
    
    /// The important information indicating that an event has happened.
    /// For example, a user was looking for kitchen chairs in a store, or a user gained 94 points out of 100 in a game.
    case info
    
    /// The unexpected information that might disturb one of the processes, but nothing bad has happened yet.
    /// That is, the code can continue the work.
    case warning
    
    /// The information about an event that cannot occur. It still allows the application to continue the work, but with some discomfort.
    /// For example, cannot open the page, no internet connection, etc.
    case error
    
    /// The information that tells that the application encountered an event or entered a state in which one of the crucial business functionality is no longer working.
    /// As a result, the application may crash.
    case fatal
    
    /// An emoji associated with this log level.
    public var emoji: String {
        switch self {
        case .trace:   return "⚪️"
        case .debug:   return "🟢"
        case .info:    return "🔵"
        case .warning: return "🟡"
        case .error:   return "🟠"
        case .fatal:   return "🔴"
        }
    }
    
}

