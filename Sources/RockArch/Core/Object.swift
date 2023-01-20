/// The object that weakly references a specific `AnyObject` instance.
///
/// Weak objects are mainly used in collections that should not strongly reference objects.
internal final class RAWeakObject: RAObject {
    
    /// The weak reference to a specific object.
    internal weak var reference: AnyObject?
    
    /// A string associated with the name of the reference object.
    internal let name: String
    
    /// A textual representation of the type of the reference object.
    internal let type: String
    
    /// Creates a weak object that stores the given `RAObject` instance in the right way.
    internal init(reference object: RAObject) {
        if let weakObject = object as? RAWeakObject {
            reference = weakObject.reference
        } else if let wrappedObject = object as? RAWrappedObject {
            reference = wrappedObject.value
        } else {
            reference = object
        }
        name = object.name
        type = object.type
    }
    
}


/// The object that wraps a specific `AnyObject` instance by strongly referencing it.
///
/// Wrapped objects are mainly used to endow the `AnyObject` instance with the behavior of a `RAObject`.
internal final class RAWrappedObject: RAObject {
    
    /// The strong reference to a specific object.
    internal let value: AnyObject
    
    /// A string associated with the name of the reference object.
    internal let name: String
    
    /// A textual representation of the type of the reference object.
    internal let type: String
    
    /// Creates a wrapped object that stores the given `AnyObject` instance.
    internal init(name: String, type: String, objectToWrap: AnyObject) {
        value = objectToWrap
        self.name = name
        self.type = type
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
