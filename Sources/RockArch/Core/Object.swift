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
