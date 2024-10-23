import UIKit

/// A view that is responsible for configurating and updating UI, catching and handling user interactions.
///
/// The `RAView` extends the `UIViewController` class by adding the properties and methods necessary to be integrated into the module.
/// This causes the view to have `name`, `type`, `state` and `module` properties.
///
/// In order to interact with the `interactor` component of the module, you use a specific communication interface.
/// This is in order to clearly delineate the work of the components and ensure clarity of interactions between them.
///
/// Now the view has two additional lifecycle methods: `setup()` and `clean()`,
/// which are called when the module is attached to or detached from the module tree.
/// It allows you to move all the logic of the view configuration from the `viewDidLoad()` method to `setup()`.
///
/// If the module has embedded children, you can access them by using the `embeddedChildren` property and
/// by redefining the `loadEmbeddedViewControllers()` method to make sure they really exist.
/// It's used if you want to custom display these child controllers.
///
/// - Note: Each component can log messages by calling the `log(_:category:level:)` method.
/// These messages are handled by the current black box with its loggers.
///
/// - Important: You should not redefine the implementation of these above properties,
/// because the compiler provides it for you using internal properties.
///
@MainActor
public protocol RAView: RAComponent, RAIntegratable where Self: UIViewController {
    
    /// A communication interface from this view to a specific interactor of this module.
    ///
    /// For example, simple interface for the authentication interactor:
    ///
    ///     protocol AuthViewToInteractorInterface {
    ///
    ///         func userDidEnterUsername(_ username: String) -> Void
    ///
    ///         func userDidEnterPassword(_ password: String) -> Void
    ///
    ///         func userDidTapLoginButton() -> Void
    ///
    ///     }
    ///
    associatedtype InteractorInterface
    
    /// An interactor that is responsible for all business logic of a module.
    var interactor: InteractorInterface? { get }
    
    /// Loads embedded view controllers of this module.
    ///
    /// This method is used when the module has embedded children.
    /// So you load the view controllers of these modules in the following way:
    ///
    ///     var messagesViewController: UIViewController!
    ///     var settingsViewController: UIViewController!
    ///
    ///     func loadEmbeddedViewControllers() -> Bool {
    ///         guard let messagesViewController = embeddedChildren[MessagesModule.name],
    ///               let settingsViewController = embeddedChildren[SettingsModule.name]
    ///         else { return false }
    ///         self.messagesViewController = messagesViewController
    ///         self.settingsViewController = settingsViewController
    ///         return true
    ///     }
    ///
    /// - Note: This method is called during the loading of the module, but before the `setup()` method of this view.
    /// - Returns: `True` if all the necessary view controllers have been loaded; otherwise, `false`.
    func loadEmbeddedViewControllers() -> Bool
    
}

extension RAView {
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "View" value.
    public var type: String { "View" }
    
    /// A module into which this view is integrated.
    /// - Note: The compiler provides default implementation of this property using internal properties.
    /// If you replace this implementation, you won't access this module.
    public var module: RAModuleInterface? { _module }
    
    /// An interactor that is responsible for all business logic of a module.
    /// - Note: The compiler provides default implementation of this property using internal properties.
    /// If you replace this implementation, you won't access this interactor.
    public var interactor: InteractorInterface? { _interactor as? InteractorInterface }
    
    /// The dictionary that stores view controllers of embedded child modules by their names.
    /// - Note: The compiler provides default implementation of this property using internal properties.
    /// If you replace this implementation, you won't access these view controllers.
    public var embeddedChildren: [String: UIViewController] {
        guard let module = _module else { return [:] }
        var dict = [String: UIViewController]()
        module.embeddedChildren.forEach { dict[$0.key] = $0.value.view }
        return dict
    }
    
    /// An internal module of this view.
    var _module: RAModule? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.module) as? RAModule }
        set { objc_setAssociatedObject(self, &AssociatedKeys.module, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    
    /// An internal interactor of this module.
    internal var _interactor: RAAnyInteractor? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.interactor) as? RAAnyInteractor }
        set { objc_setAssociatedObject(self, &AssociatedKeys.interactor, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// Setups this view before it starts working.
    ///
    /// This method is called when the module into which this view integrated is assembled and loaded into the module tree.
    /// You define a new implementation for this method to perform additional initialization on your private properties.
    /// - Note: This method is called after the `viewDidLoad()` method and before the `viewWillAppear()` method.
    public func setup() -> Void {}
    
    /// Cleans this view after it stops working.
    ///
    /// This method is called when the module into which this view integrated is about to be unloaded from the module tree and disassembled.
    /// You define a new implementation for this method to clean your properties.
    /// - Note: This method is called after the `viewDidDisappear()` method and before the `viewWillUnload()` method.
    public func clean() -> Void {}
    
    public func loadEmbeddedViewControllers() -> Bool { true }
    
}



private struct AssociatedKeys {
    static var module = "com.memoca.module".hashValue
    static var interactor = "com.memoca.interactor".hashValue
}
