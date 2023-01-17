/// A context within which a module starts the work.
///
/// When one module shows another, it can pass a context in order to indicate key information.
///
/// For example, you have a table with friends, when a user clicks on a row, you show a friend profile.
/// So, you have the `FriendsModule` and `FriendProfileModule` classes.
/// That is, the context for the second module is a `friendID` that you pass from the first module.
public typealias RAContext = Any


/// An outcome with which a module stops the work.
///
/// When a module hides, it can pass an outcome of its work to a parent module.
///
/// For example, you have settings where a user can choose an acсent color for the application.
/// So, you have the `SettingsModule` and `ColorPickerModule` classes.
/// That is, the outcome of the second module is a `chosenColor` that you receive in the first module.
public typealias RAOutcome = Any


/// A dependency that is injected in a module during loading.
///
/// When one module loads another, it can pass a dependency that should be injected.
/// It's usually a single service or multiple ones.
public typealias RADependency = Any


/// A signal that is passed from one object to another.
///
/// The signal is used by modules to communicate with each other. Signals can be as follows:
///
///     let signal1 = RASignal(label: "current_score", value: 79)
///     let signal2 = RASignal(label: "chosen_color", value: UIColor.blue)
///     let signal3 = RASignal(label: "typed_text", value: "hello")
///
public struct RASignal: CustomStringConvertible {
    
    /// A passed value.
    public let value: Any
    
    /// A string value that describes a passed value.
    public let label: String
    
    /// A textual representation of this signal.
    public var description: String {
        let label = label.isEmpty ? "Unnamed" : label
        return "\(label)-Signal"
    }
    
    /// Creates a named signal with some value.
    public init(label: String, value: Any) {
        self.label = label
        self.value = value
    }
    
}


/// An associated object that is relative of another object.
///
/// For example, the **A** module loads the **B** module into its memory.
/// That is, **A** becomes a **parent** for **B**, and **B** becomes a **child** for **A**.
public enum RARelative: Equatable {
    
    /// A child of this object.
    case child(String)
    
    /// A parent of this object.
    case parent
    
}


/// An empty type that will be ignored by others.
internal protocol RAEmpty {}
