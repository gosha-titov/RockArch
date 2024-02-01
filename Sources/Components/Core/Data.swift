import UIKit

/// A dependency that is injected in a module during loading.
///
/// When one module loads another, it can pass a dependency that should be injected.
/// It's usually a single service or multiple ones.
public typealias RADependency = Any



/// A context containing the key information for a module to start its work.
///
/// When one module shows another, it can pass a context in order to indicate key information.
///
/// For example, you have a table with friends, when a user clicks on a row, you show a friend profile.
/// So, you have the `FriendsModule` and `FriendProfileModule` classes.
/// That is, the context for the second module is a `friendID` that you pass from the first module.
public typealias RAContext = Any



/// A result with which a module stops the work.
///
/// When a module completes, it can pass a result of its work to a parent module.
///
/// For example, you have settings where a user can choose an acсent color for the application.
/// So, you have the `AppearanceModule` and `ColorPickerModule` classes.
/// That is, the result of the second module is a `chosenColor` that you handle in the first module.
public typealias RAResult = Any



/// A signal that is passed from one module to another.
///
/// Signals are used by modules to communicate with each other.
/// It's not only when the child module sends something to its parent (or in the reverse direction),
/// but also when any module sends something to another one from the module tree.
///
/// Signals can be as follows:
///
///     let signal1 = RASignal(label: "current_score", value: 79)
///     let signal2 = RASignal(label: "chosen_color", value: UIColor.blue)
///     let signal3 = RASignal(label: "typed_text", value: "hello")
///
///     let signal4 = RASignal(
///         label: "new_color_scheme",
///         value: ColorScheme.sunset
///     )
///
public struct RASignal: CustomStringConvertible {
    
    /// The passed value.
    public let value: Any
    
    /// The string that describes the passed value.
    public let label: String
    
    /// A textual representation of this signal.
    ///
    /// Returns the label value if not empty; otherwise, "unnamed".
    public var description: String {
        return label.isEmpty ? "unnamed" : label
    }
    
    /// Creates a named signal instance with a value.
    public init(label: String, value: Any) {
        self.label = label
        self.value = value
    }
    
}



/// An animation of showing or hiding a view controller.
///
/// This closure has no return value and takes only one parameter: a child view controller to animate.
/// It's used to show and hide a child module when it starts/stops working.
///
///     let presentChildViewController: RADefaultAnimation = { childViewController in
///         viewController.present(childViewController, animated: false)
///     }
///
internal typealias RADefaultAnimation = (UIViewController) -> Void
