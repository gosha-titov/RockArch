import UIKit

public protocol RAView: RAComponent, RAIntegratable where Self: UIViewController {
    
    /// Loads embedded view controllers.
    ///
    /// This method is used when the module has embedded children.
    /// So you load the view controllers of these modules in the following way:
    ///
    ///     let messagesViewController: UIViewController!
    ///     let settingsViewController: UIViewController!
    ///
    ///     func loadEmbeddedViewControllers() -> Bool {
    ///         guard let messagesViewController = embeddedChildren["Messages"],
    ///               let settingsViewController = embeddedChildren["Settings"]
    ///         else {
    ///             return false
    ///         }
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
    /// - Note: It's the default implementation of this property that uses internal properties.
    /// If you replace this implementation, you won't access this module.
    public var module: RAModuleInterface? { _module }
    
    /// The dictionary that stores view controllers of embedded child modules by their names.
    /// - Note: It's the default implementation of this property that uses internal properties.
    /// If you replace this implementation, you won't access these view controllers.
    public var embeddedChildren: [String: UIViewController] {
        guard let module = _module else { return [:] }
        var dict = [String: UIViewController]()
        module.embeddedChildren.forEach { dict[$0.key] = $0.value.view }
        return dict
    }
    
    /// An internal module of this view.
    internal var _module: RAModule? {
        get {
            let storage = RAWeakModuleStorage.shared
            return storage[debugDescription]
        }
        set {
            let storage = RAWeakModuleStorage.shared
            storage[debugDescription] = newValue
        }
    }
    
    /// An internal interactor of this module.
    internal var _interactor: RAInteractor? {
        get {
            let storage = RAWeakInteractorStorage.shared
            return storage[debugDescription]
        }
        set {
            let storage = RAWeakInteractorStorage.shared
            storage[debugDescription] = newValue
        }
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
