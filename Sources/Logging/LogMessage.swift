import Foundation
import os

/// A personalized log message that also contains a context within which it's created.
///
/// You almost never create a log message directly. You only filter and process it inside a logger.
///
/// The log message looks like in the following example:
///
///     message.author        // "Menu-Interactor"
///     message.text          // "User gained 97 points out of 100"
///     message.category      // "User"
///     message.level         // .info
///     message.info.file.id  // "MindGame/MenuInteractor.swift"
///     message.info.function // "child(_:didPassOutcome:)"
///     message.info.line     // 132
///     message.timestamp     // "2023-06-09 14:05:43 +0000"
///     message.uuid          // "D24A7E1C-B5D9-4F53-B96F-C8B248172DF8"
///
public struct RALogMessage: Equatable {
    
    /// The string that describes an author of this log message.
    public let author: String
    
    /// The text of this log message.
    public let text: String
    
    /// The string that describes a category of this log message.
    public let category: String
    
    /// The level associated how important this log message is.
    public let level: RALogLevel
    
    /// The information about a file, function and line this instance originates from.
    public let info: RAInfo
    
    /// The time when this log message was created.
    public let timestamp: Date
    
    /// The universally unique value of this log message.
    public let uuid: UUID
    
    /// Creates a log message instance.
    /// - Parameter author:    The string that describes an author of this log message.
    /// - Parameter text:      The text of this log message.
    /// - Parameter category:  The string that describes a category of this log message.
    /// - Parameter level:     The level associated how important this log message is.
    /// - Parameter info:      The information about a file, function and line this instance originates from.
    /// - Parameter timestamp: The time when this log message was created.
    /// - Parameter uuid:      The universally unique value of this log message.
    public init(author: String, text: String, category: String, level: RALogLevel, info: RAInfo, timestamp: Date = .init(), uuid: UUID = .init()) {
        self.author = author
        self.text = text
        self.category = category
        self.level = level
        self.info = info
        self.timestamp = timestamp
        self.uuid = uuid
    }
    
}



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
    
}



// MARK: - Extensions

extension RALogMessage {
    
    public static func == (lhs: RALogMessage, rhs: RALogMessage) -> Bool {
        return lhs.author == rhs.author && lhs.text == rhs.text && lhs.category == rhs.category && lhs.level == rhs.level
            && lhs.info == rhs.info && lhs.timestamp == rhs.timestamp && lhs.uuid == rhs.uuid
    }
    
}

extension RALogLevel {
    
    public static func < (lhs: RALogLevel, rhs: RALogLevel) -> Bool {
        return lhs.integerValue < rhs.integerValue
    }
    
}
