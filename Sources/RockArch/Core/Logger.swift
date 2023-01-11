import Foundation

/// A default logger that prints messages to the console.
///
/// You don't interact with this logger directly. You can only use it as one of the parameters for the black box.
/// The console black box uses this logger by default.
///
/// The console logger prints incoming messages in the following way:
///
///     "[Network] 17:46:52 PM <error> Weather-Service: No internet connection."
///      category   timestamp   level      author                text
///
public final class RAConsoleLogger: RALogger {
    
    /// A string associated with the name of this logger.
    public let name = "Console"
    
    /// Logs a specific message.
    public final func log(_ message: RALogMessage) -> Void {
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
    
}


/// A type that can log messages in a simplified way.
///
/// It allows you not to specify an author of a log message because the author is always this object.
/// A new (simplified) way of logging:
///
///     log("No internet connection", category: "Network", level: .error)
///
/// and usual (long) way of logging:
///
///     RABlackBox.error("No internet connection", author: "Main-Interactor", category: "Network")
///
public protocol RASimplifiedLoggable where Self: RAObject {
    
    /// Logs a message in a simplified way by specifying a sender as this object.
    ///
    /// Call this method when you need to log a message on behalf of this object.
    /// For example, if the black box uses a console logger:
    ///
    ///     log("No internet connection", category: "Network", level: .error)
    ///
    /// will print:
    ///
    ///     "[Network] 7:26:33 PM <error> Main-Interactor: No internet connection."
    ///
    /// - Parameter message:  A string to log.
    /// - Parameter category: A string that describes a category of this message.
    /// - Parameter level:    A level with which this message will be logged.
    func log(_ message: String, category: String, level: RALogLevel, fileID: String, function: String, line: Int) -> Void
    
}

public extension RASimplifiedLoggable {
    
    func log(_ message: String, category: String, level: RALogLevel = .debug, fileID: String = #fileID, function: String = #function, line: Int = #line) -> Void {
        RABlackBox.log(message, author: description, category: category, level: level, fileID: fileID, function: function, line: line)
    }
    
}


/// A type that can log the messages.
///
/// The logger is used by the `RABlackBox` that passes all incoming log messages to it.
///
/// By default, the black box uses the console logger, but if you need to redirect or customize the printing of log messages,
/// then you define a new class that conforms to the `RALogger` protocol, and set it for the black box.
public protocol RALogger: RAObject {
    
    /// Logs a specific message.
    func log(_ message: RALogMessage) -> Void
    
}

public extension RALogger {
    
    /// A textual representation of the type of this logger.
    var type: String {
        return "Logger"
    }
    
}


/// A personalized log message that also contains a context within which it's created.
///
/// You almost never create a log message directly. You only process and/or filter it. The log messages looks something like this:
///
///     message.author        // "Menu-Interactor"
///     message.text          // "User gained 97 points out of 100"
///     message.category      // "User"
///     message.level         // .info
///     message.info.file.id  // "MindGame/MenuInteractor.swift"
///     message.info.function // "child(_:didPassOutcome:)"
///     message.info.line     // 132
///     message.timestamp     // "2023-01-07 18:11:43 +0000"
///     message.uuid          // "D24A7E1C-B5D9-4F53-B96F-C8B248172DF8"
///
public struct RALogMessage {
    
    /// The string that describes an author of this log message.
    public let author: String
    
    /// The text of this log message.
    public let text: String
    
    /// The string that describes a category of this log message.
    public let category: String
    
    /// The level associated how important this log message is.
    public let level: RALogLevel
    
    /// The information about a file, function and line in which this log message was created.
    public let info: RAInfo
    
    /// The time when this log message was created.
    public let timestamp: Date
    
    /// The universally unique value of this log message.
    public let uuid: UUID
    
    /// Creates a log instance.
    /// - Parameter author: A string that describes an author of this log message.
    /// - Parameter text: A text of this log message.
    /// - Parameter category: A string that describes a category of this log message.
    /// - Parameter level: A level associated how important this log message is.
    /// - Parameter info: An information about a file, function and line in which this log messasge is created.
    public init(author: String, text: String, category: String, level: RALogLevel, info: RAInfo) {
        self.author = author
        self.text = text
        self.category = category
        self.level = level
        self.info = info
        timestamp = .init()
        uuid = .init()
    }
    
}

    
/// A level associated how important a log message is.
///
/// There are 6 kinds of log level: trace, debug, info, warning, error and fatal.
public enum RALogLevel: String, CaseIterable, Comparable {
    
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
    
    /// Returns an emoji associated with this log level.
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
    
    /// Returns an integer associated with this log level.
    public var integer: Int {
        switch self {
        case .trace:   return 0
        case .debug:   return 1
        case .info:    return 2
        case .warning: return 3
        case .error:   return 4
        case .fatal:   return 5
        }
    }
    
    public static func < (lhs: RALogLevel, rhs: RALogLevel) -> Bool {
        return lhs.integer < rhs.integer
    }
    
}
