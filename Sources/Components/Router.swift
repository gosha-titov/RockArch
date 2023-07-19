import UIKit

open class RARouter: RAComponent, RAIntegratable {
    
    // MARK: - Properties
    
    /// A module into which this router is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this router
    internal weak var _module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Router" value.
    public let type: String = "Router"
    
    /// The transition with which this module was shown.
    public internal(set) var transition: Transition = .none
    
    
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
    
    
    // MARK: - Routing
    
    /// Presents a view controller of a specific child module modally.
    ///
    /// You can present a child module only if there's at least one view controller in this flow.
    /// When you do this, you load, start and present the child module.
    /// - Note: If you present the child module that has no view, then you just load it and see the error in log messages.
    /// - Parameter childName: The associated name of a module to load, start and present.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true.`
    /// - Parameter completion: The block to execute after the presentation finishes.
    /// This block has no return value and takes no parameters. The default value is `nil.`
    /// - Returns: `True` if the child module has been presented; otherwise, `false`.
    @discardableResult
    public final func presentChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard let module = _module else {
            log("Couldn't present the \(childName) child module because this router didn't integrated into any module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let viewControllerThatPresents = firstViewController else {
            log("Couldn't present the \(childName) child module because this flow didn't have any view controller",
                category: .moduleRouting, level: .error)
            return false
        }
        guard module.loadChild(byName: childName) else {
            log("Couldn't present the \(childName) child module because it wasn't be loaded",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let child = module.router(of: .child(childName)), let childViewController = child.viewController else {
            log("Couldn't present the \(childName) child module because it didn't have a view",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard module.invokeChild(byName: childName) else {
            log("Couldn't present the \(childName) child module because it wasn't be invoked",
                category: .moduleRouting, level: .error)
            return false
        }
        viewControllerThatPresents.present(childViewController, animated: animated, completion: completion)
        child.transition = .presented
        return true
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
    
    
    // MARK: - Init and Deinit
    
    /// Creates a router instance.
    public init() {
        RALeakDetector.register(self)
    }
    
    deinit {
        RALeakDetector.release(self)
    }
    
}



extension RARouter {
    
    public enum Transition {
        case presented
        case pushed
        case selected
        case none
    }
    
}
