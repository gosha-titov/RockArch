import UIKit

open class RARouter: RAComponent, RAIntegratable {
    
    /// A module into which this router is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this router
    internal weak var _module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Router" value.
    public let type: String = "Router"
    
    
    // MARK: View Controllers
    
    /// A view controller of this module.
    internal weak var viewController: UIViewController?
    
    /// A view controller of this module casted to the navigation controller.
    internal final var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    /// A view controller of this module casted to the tab bar controller.
    internal final var tabBarController: UITabBarController? {
        return viewController as? UITabBarController
    }
    
    /// A navigation controller that pushed a view controller of this module.
    internal weak var sharedNavigationController: UINavigationController?
    
    /// A first view controller found in this flow.
    internal final var firstViewController: UIViewController? {
        let parent = _module?.router(of: .parent)
        return viewController ?? parent?.firstViewController
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this router before it starts working.
    ///
    /// This method is called when the module into which this router integrated is assembled but not yet loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this router after it stops working.
    ///
    /// This method is called when the module into which this router integrated is about to be unloaded from the module tree and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    
    // MARK: - Init
    
    /// Creates a router instance.
    public init() {}
    
}
