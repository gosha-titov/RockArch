import UIKit

open class RARouter: RAComponentIntegratedIntoModule {
    
    // MARK: - Properties
    
    /// A module to that this router belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Router" value.
    public let type: String = "Router"
    
    /// The array of route actions that are mainly used by deep links.
    public private(set) var routeActions = [String: RARouteAction]()
    
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
    internal var sharedNavigationController: UINavigationController?
    
    /// A view controller that was last used in this flow.
    internal var previousViewController: UIViewController?
    
    
    // MARK: - Route Action Management
    
    /// Adds the given route action for a specific child.
    public final func add(routeAction: RARouteAction, forChild childName: String) -> Void {
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
        }
        routeActions.removeValue(forKey: childName)
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
