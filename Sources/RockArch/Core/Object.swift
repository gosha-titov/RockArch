/// An object that weakly references a specific object.
///
/// Weak objects are mainly used in collections that should not strongly reference objects.
open class RAWeakObject: RAObject {
    
    /// The reference to a specific object.
    public weak var reference: RAObject?
    
    /// A string associated with the name of the reference object.
    public let name: String
    
    /// A textual representation of the type of the referenc object.
    public let type: String
    
    /// Creates a weak object that references a specific object.
    public init(reference: RAObject) {
        self.reference = reference
        name = reference.name
        type = reference.type
    }
    
}


/// A named reference-type object that has a description.
public protocol RAObject: AnyObject, CustomStringConvertible {
    
    /// A string associated with the name of this object.
    var name: String { get }
    
    /// A textual representation of the type of this object.
    var type: String { get }
    
}

public extension RAObject {
    
    /// A textual representation of this object.
    ///
    /// By default, it look like this:
    ///
    ///     "Root-Module"
    ///     "Profile-Interactor"
    ///     "Settings-View"
    ///     "Main-Router"
    ///     "Appearance-Builder"
    ///     "Console-Logger"
    ///
    /// It's mainly used in log messages.
    var description: String {
        return "\(name)-\(type)"
    }
    
}
