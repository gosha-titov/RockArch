import os

/// A level associated how important a log message is.
///
/// There are 6 kinds of log level: `.trace`, `.debug`, `.info`, `.warning`, `.error` and `.fatal`. They are ordered by their severity, with `.trace` being the least severe and `.fatal` being the most severe.
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
    
    /// An integer associated with this log level.
    public var integerValue: Int {
        switch self {
        case .trace:   return 0
        case .debug:   return 1
        case .info:    return 2
        case .warning: return 3
        case .error:   return 4
        case .fatal:   return 5
        }
    }
    
    /// An OSLogType value converted from this log level.
    public var toOSLogType: OSLogType {
        switch self {
        case .trace:   return .debug
        case .debug:   return .default
        case .info:    return .info
        case .warning: return .error
        case .error:   return .error
        case .fatal:   return .fault
        }
    }
    
    public static func < (lhs: RALogLevel, rhs: RALogLevel) -> Bool {
        return lhs.integerValue < rhs.integerValue
    }
    
}
