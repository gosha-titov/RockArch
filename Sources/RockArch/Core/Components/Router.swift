import UIKit

open class RARouter: RAComponentIntegratedIntoModule {
    
    // MARK: - Public Properties
    
    /// A module to that this router belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Router" value.
    public let type: String = "Router"
    
    /// The array of route actions that are mainly used by deep links.
    public private(set) var defaultTransitions = [String: RATransition]()
    
    /// The array of names of child modules that are currently in the tab bar.
    public private(set) var namesOfTabModules = [String]()
    
    
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
    
    
    // MARK: Private Properties
    
    /// The array of names of child modules that should be added to the tab bar.
    private var namesOfModulesThatShouldBeTabs = [String]()
    
    
    // MARK: - Routing
    
    /// Presents a view controller of a specific child module modally.
    ///
    /// You can present a child module only in two cases: when this module has a view that is a view controller or when there's a view controller in this flow.
    /// When you do this, you load, start and display the child module.
    ///
    /// You can also present the child module that has no view. In this case, you just load and start it.
    ///
    /// - Parameter childName: The name of a module to load, start and present.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// You might specify `false` if you are setting up the navigation controller at launch time. The default value is `true.`
    /// - Parameter completion: The block to execute after the presentation finishes.
    /// This block has no return value and takes no parameters. The default value is `true.`
    ///
    /// - Returns: `True` if the child module has been presented; otherwise, `false`.
    @discardableResult
    public final func presentChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard let module else {
            log("Couldn't present the \(childName) child module because this router doesn't belong to any module",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let viewController = viewController ?? previousViewController else {
            log("Couldn't present the \(childName) child module because this router doesn't have any view controller",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard module.invokeChildModule(byName: childName) else {
            log("Couldn't present the \(childName) child module because it cannot be invoked",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let child = module.router(of: .child(childName)) else {
            // Will never happen because a child module is definitely loaded
            return false
        }
        if let childViewController = child.viewController {
            viewController.present(childViewController, animated: animated, completion: completion)
        }
        return true
    }
    
    /// Pushes a view controller of a specific child module onto a navigation stack.
    ///
    /// You can push a child module only in two cases: when this module was pushed or when this module has a view that is a navigation controller.
    /// When you do this, you load, start and display the child module.
    ///
    /// You can also push the child module that has no view. In this case, you just load and start it, and share a navigation controller to it.
    ///
    /// - Note: When the **A** module pushes the **B** child module, **A** shares a navigation controller to **B**.
    /// That is, **B** is also able to push its child modules.
    ///
    /// - Parameter childName: The name of a module to load, start and push.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// You might specify `false` if you are setting up the navigation controller at launch time. The default value is `true.`
    /// - Parameter completion: The block to execute after the pushing finishes.
    /// This block has no return value and takes no parameters. The default value is `true.`
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
        guard module.invokeChildModule(byName: childName) else {
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
            navigationController.push(childViewController, animated: animated, completion: completion)
        }
        child.sharedNavigationController = navigationController
        return true
    }
    
    /// Selects a view controller of a specific child module.
    ///
    /// You can present a child module only when this module has a tab bar controller.
    /// When you do this, you start and display the child module.
    ///
    /// In order to specify tab modules, you should override the `setup()` method of the module to which this router belongs
    /// and mark some modules as integrated:
    ///
    ///     final class MainModule: RAModule {
    ///
    ///         override func setup() -> Void {
    ///             markModuleAsIntegrated(byName: "Feed")
    ///             markModuleAsIntegrated(byName: "Messages")
    ///             markModuleAsIntegrated(byName: "Settings")
    ///         }
    ///
    ///     }
    ///
    /// And then mark specific modules from them as tabs:
    ///
    ///     final class MainRouter: RARouter {
    ///
    ///         override func setup() -> Void {
    ///             markIntegratedModuleAsTab(byName: "Feed")
    ///             markIntegratedModuleAsTab(byName: "Messages")
    ///             markIntegratedModuleAsTab(byName: "Settings")
    ///         }
    ///
    ///     }
    ///
    /// - Parameter childName: The name of a module to start and select.
    /// - Parameter completion: The block to execute after the selecting finishes.
    /// This block has no return value and takes no parameters. The default value is `true.`
    ///
    /// - Returns: `True` if the child module has been selected; otherwise, `false`.
    @discardableResult
    public final func selectChildModule(byName childName: String, completion: (() -> Void)? = nil) -> Bool {
        guard let module else {
            log("Couldn't select the \(childName) child module because this router doesn't belong to any module",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let tabBarController else {
            log("Couldn't select the \(childName) child module because this router doesn't have a tab bar controller",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard let tabIndex = namesOfTabModules.firstIndex(of: childName) else {
            log("Couldn't select the \(childName) child module because it's not a tab",
                category: .moduleRouting,
                level: .error)
            return false
        }
        guard module.invokeChildModule(byName: childName) else {
            log("Couldn't select the \(childName) child module because it cannot be invoked",
                category: .moduleRouting,
                level: .error)
            return false
        }
        tabBarController.selectedIndex = tabIndex
        completion?()
        return true
    }
    
    
    // MARK: - Transition Management
    
    /// Sets the given transition for a specific child.
    public final func setDefaultTransition(_ transition: RATransition, forChild childName: String) -> Void {
        if defaultTransitions[childName].hasValue {
            log("Replaced an existing transition for the `\(childName)` child module",
                category: .moduleRouting,
                level: .warning)
        }
        defaultTransitions[childName] = transition
    }
    
    /// Removes a transition for a specific child.
    public final func removeDefaultTransition(forChild childName: String) -> Void {
        if defaultTransitions[childName].isNil {
            log("Attempt to remove a non-existent transition for the `\(childName)` child module",
                category: .moduleRouting,
                level: .warning)
        } else {
            defaultTransitions.removeValue(forKey: childName)
        }
    }
    
    
    // MARK: - Tab Bar Setuping
    
    /// Marks a specific integrated module as a tab.
    ///
    /// You use it when the module has a tab bar controller:
    ///
    ///     override func setup() -> Void {
    ///         markIntegratedModuleAsTab(byName: "Feed")
    ///         markIntegratedModuleAsTab(byName: "Messages")
    ///         markIntegratedModuleAsTab(byName: "Settings")
    ///     }
    ///
    /// Be sure, that you mark them for the module to which this router belongs:
    ///
    ///     final class MainModule: RAModule {
    ///
    ///         override func setup() -> Void {
    ///             markModuleAsIntegrated(byName: "Feed")
    ///             markModuleAsIntegrated(byName: "Messages")
    ///             markModuleAsIntegrated(byName: "Settings")
    ///         }
    ///
    ///     }
    ///
    public final func markIntegratedModuleAsTab(byName childName: String) -> Void {
        guard let module else {
            log("Couldn't mark the `\(childName)` child module as a tab because this router didn't belong to any module",
                category: .moduleRouting,
                level: .error)
            return
        }
        guard tabBarController.hasValue else {
            log("Couldn't mark the `\(childName)` child module as a tab because the module didn't have a tab bar controller",
                category: .moduleRouting,
                level: .error)
            return
        }
        guard module.namesOfIntegratedModules.contains(childName) else {
            log("Couldn't mark the `\(childName)` child module as a tab because the module didn't integrate this module",
                category: .moduleRouting,
                level: .error)
            return
        }
        guard namesOfModulesThatShouldBeTabs.contains(childName) == false else {
            log("Couldn't mark the `\(childName)` child module as a tab because it was already marked",
                category: .moduleRouting,
                level: .error)
            return
        }
        namesOfModulesThatShouldBeTabs.append(childName)
    }
    
    /// Setups a tab bar controller if the module has it.
    private func setupTabBarControllerIfNeeded() -> Void {
        guard let module, let tabBarController else { return }
        guard module.isLoaded == false else {
            log("Couldn't setup a tab bar controller because the module was already loaded",
                category: .moduleRouting,
                level: .error)
            return
        }
        guard module.namesOfIntegratedModules.count > 0 else {
            log("Couldn't setup a tab bar controller because integrated modules weren't specified",
                category: .moduleRouting,
                level: .error)
            return
        }
        let childNames = namesOfModulesThatShouldBeTabs
        var childViewControllers = [UIViewController]()
        for childName in childNames {
            if let child = module.router(of: .child(childName)),
               let childViewController = child.viewController {
                childViewControllers.append(childViewController)
                namesOfTabModules.append(childName)
            } else {
                log("Couldn't add the `\(childName)` child module to a tab bar because it didn't have a view controller",
                    category: .moduleRouting,
                    level: .error)
            }
        }
        tabBarController.setViewControllers(childViewControllers, animated: false)
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
        RALeakDetector.register(self)
        setup()
        setupTabBarControllerIfNeeded()
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal final func _clean() -> Void {
        clean()
    }
    
    
    // MARK: - Public Init
    
    /// Creates a router instance.
    public init() {}
    
}


public enum RATransition {
    case presenting
    case pushing
    case selecting
    case jumping
    case custom(RAAnimation)
}


/// A router that is marked as empty.
internal final class RAEmptyRouter: RARouter, RAEmpty {}
