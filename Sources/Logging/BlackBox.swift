/// The black box that records all incoming messages by passing them to its loggers.
open class RABlackBox: RAAnyObject {
    
    /// A string associated with the name of this black box.
    public let name: String
    
    /// A textual representation of the type of this black box.
    ///
    /// This property has the "BlackBox" value.
    public let type = "BlackBox"
    
    /// Creates a black box instance.
    public init(name: String) {
        self.name = name
    }
    
}
