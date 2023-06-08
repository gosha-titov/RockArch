/// A named typed reference-type object that has a description.
///
/// Classes that conform to the `RAAnyObject` protocol can be identified by the `name` and `type` properties:
///
///     object.name // "Appearance"
///     object.type // "Module"
///
/// All key classes conform to the `RAAnyObject` protocol.
public protocol RAAnyObject: RAObject, AnyObject {}



/// A named typed object that has a description.
///
/// Types that conform to the `RAObject` protocol can be identified by the `name` and `type` properties:
///
///     object.name // "Settings"
///     object.type // "Interactor"
///
/// All key types conform to the `RAObject` protocol.
public protocol RAObject: CustomStringConvertible {
    
    /// A string associated with the name of this object.
    var name: String { get }
    
    /// A textual representation of the type of this object.
    var type: String { get }
    
}

public extension RAObject {
    
    /// A textual representation of this object.
    ///
    /// By default, it returns a string concatenating the name and the type of this object:
    ///
    ///     module.description     // "Root-Module"
    ///     interactor.description // "Profile-Interactor"
    ///     router.description     // "Main-Router"
    ///     view.description       // "Settings-View"
    ///     builder.description    // "Appearance-Builder"
    ///     logger.description     // "Console-Logger"
    ///
    /// It's mainly used in log messages.
    var description: String {
        return "\(name)-\(type)"
    }
    
}
