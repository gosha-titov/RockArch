import Foundation

/// The black box that records all incoming messages by passing them to its loggers.
open class RABlackBox: RAAnyObject {
    
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
    
    /// Creates a black box instance with specific loggers that will log messages in the given queue.
    /// - Parameter name: The string associated with the name of this black box.
    /// - Parameter loggers: Loggers that will receive all messages coming into this black box.
    /// - Parameter queue: The queue in which logging will be performed. To keep the correct order of messages, pass a serial queue.
    public init(name: String, loggers: [RALogger], queue: DispatchQueue) {
        self.loggers = loggers
        self.queue = queue
        self.name = name
    }
    
}
