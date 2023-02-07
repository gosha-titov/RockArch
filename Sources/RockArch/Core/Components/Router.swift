import UIKit

open class RARouter: RAComponentIntegratedIntoModule {
    
    // MARK: - Public Properties
    
    /// A module to that this router belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Router" value.
    public let type: String = "Router"
    
    /// The array of route actions that are mainly used by deep links.
    public private(set) var routeActions = [String: RARouteAction]()
    
    
    // MARK: Internal Properties
    
    /// A view controller of this module.
    internal var viewController: UIViewController?
    
    /// A view controller of this module casted to the navigation controller.
    internal var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    /// A view controller of this module casted to the tab bar controller.
    internal var tabBarController: UITabBarController? {
        return viewController as? UITabBarController
    }
    
    /// A navigation controller that pushed a view controller of this module.
    internal weak var sharedNavigationController: UINavigationController?
    
    /// A view controller that was last used in this flow.
    internal var previousViewController: UIViewController? {
        let parent = module?.router(of: .parent)
        return parent?.viewController ?? parent?.previousViewController
    }
    
    
    // MARK: - Routing
    
    /// Pushes a view controller of a specific child module onto a navigation stack.
    ///
    /// You can push a child module only in two cases: when this module was pushed or when this module has a view that is a navigation controller.
    /// When you do this, you load, start and show the child module.
    ///
    /// You can also push the child module that has no view. In this case, you just share a navigation controller to it.
    ///
    /// - Note: When the **A** module pushes the **B** child module, **A** shares a navigation controller to **B**.
    /// That is, **B** is also able to push its child modules.
    ///
    /// - Parameter childName: The name of a module to load, start and push.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// You might specify `false` if you are setting up the navigation controller at launch time. The default value is `true.`
    /// - Parameter completion: The block to execute after the pushing finishes.
    /// This block has no return value and takes no parameters. You may specify `nil` for this parameter.
    ///
    /// - Returns: `True` if the child module has been pushed; otherwise, `false`.
    @discardableResult
    public final func pushChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard let module else {
            log("Couldn't push the \(childName) child module because this router doesn't belong to any module",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let navigationController = navigationController ?? sharedNavigationController else {
            log("Couldn't push the \(childName) child module because this router doesn't have any navigation controller",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard module.invoke(by: childName) else {
            log("Couldn't push the \(childName) child module because it cannot be invoked",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let child = module.router(of: .child(childName)) else {
            // Will never happen because a child module is definitely loaded
            return false
        }
        if let childViewController = child.viewController {
            navigationController.push(childViewController, animated: animated, completion: completion ?? {})
        }
        child.sharedNavigationController = navigationController
        return true
    }
    
    
    // MARK: - Route Action Management
    
    /// Adds the given route action for a specific child.
    public final func addRouteAction(_ routeAction: RARouteAction, forChild childName: String) -> Void {
        if routeActions[childName].hasValue {
            log("Replaced an existing route action for the `\(childName)` child module",
                category: .moduleRouting,
                level: .warning)
        }
        routeActions[childName] = routeAction
    }
    
    /// Removes a route action for a specific child.
    public final func removeRouteAction(forChild childName: String) -> Void {
        if routeActions[childName].isNil {
            log("Attempt to remove a non-existent route action for the `\(childName)` child module",
                category: .moduleRouting,
                level: .warning)
        } else {
            routeActions.removeValue(forKey: childName)
        }
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this router.
    ///
    /// This method is called when the module to which this router belongs is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this router.
    ///
    /// This method is called when the module to which this router belongs is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    /// Called when the module is loaded into memory and assembled.
    internal final func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal final func _clean() -> Void {
        clean()
    }
    
    
    // MARK: - Public Init
    
    /// Creates a router instance.
    public init() {}
    
}


public enum RARouteAction {
    case push
    case present
    case select
    case jump
    case custom(RAAnimation)
}


/// A router that is marked as empty.
internal final class RAEmptyRouter: RARouter, RAEmpty {}
