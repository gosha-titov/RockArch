import UIKit

open class RAModule: RAComponent {
    
    // MARK: - Public Properties
    
    /// A string associated with the name of this module.
    public let name: String
    
    /// A textual representation of the type of this module.
    public let type: String = "Module"
    
    /// The current state of this module.
    public private(set) var state: RAComponentState = .inactive
    
    /// A logger that logs messages.
    public internal(set) var logger: RALogger?
    
    
    // MARK: - Public Init
    
    /// Creates a named module.
    public init(name: String) {
        self.name = name
    }
    
}
