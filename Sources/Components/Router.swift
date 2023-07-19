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
    
    public private(set) var namesOfTabModules = [String]()
    
    /// The array of names of child modules that should be added to the tab bar.
    private var namesOfChildrenThatShouldBeTabs = [String]()
    
    
    // MARK: View Controllers
    
    /// A view controller of this module.
    public internal(set) weak var viewController: UIViewController?
    
    /// A view controller of this module casted to the navigation controller.
    public final var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    /// A view controller of this module casted to the tab bar controller.
    public final var tabBarController: UITabBarController? {
        return viewController as? UITabBarController
    }
    
    /// A navigation controller that pushed a view controller of this module.
    public internal(set) weak var sharedNavigationController: UINavigationController?
    
    /// A first view controller found in this flow.
    public final var firstViewController: UIViewController? {
        let parent = _module?.router(of: .parent)
        return viewController ?? parent?.firstViewController
    }
    
    
    // MARK: - Routing
    
    /// Presents a view controller of a specific child module modally.
    ///
    /// The presentation represents the loading, building and presenting a child module.
    /// You can present a child module only if there's at least one view controller in this flow.
    ///
    /// - Note: If you present the child module that has no view, then you just load it and see the error in log messages.
    ///
    /// - Parameter childName: The associated name of a module to be present.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true.`
    /// - Parameter completion: The block to execute after the presentation finishes.
    /// This block has no return value and takes no parameters. The default value is `nil.`
    ///
    /// - Returns: `True` if the child module has been presented; otherwise, `false`.
    @discardableResult
    public final func presentChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard isActive else {
            log("Couldn't present the \(childName) child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return false
        }
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
        guard module.loadChild(byName: childName), let child = module.router(of: .child(childName)) else {
            log("Couldn't present the \(childName) child module because it wasn't be loaded",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let childViewController = child.viewController else {
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
    
    /// Pushes a view controller of a specific child module onto a navigation stack.
    ///
    /// The pushing process represents the loading, starting and pushing a child module.
    /// You can push a child module in two cases: (1) if this module has a view that is a navigation controller,
    /// or (2) if this module is pushed by another navigation controller.
    ///
    /// You can also push the child module that has no view. In this case, you build, load, start it and then share a navigation controller to it.
    ///
    /// - Note: When the **A** module pushes the **B** child module, **A** shares a navigation controller to **B**.
    /// That is, **B** is also able to push its child modules.
    ///
    /// - Parameter childName: The associated name of a module to be pushed.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true.`
    /// - Parameter completion: The block to execute after the pushing finishes.
    /// This block has no return value and takes no parameters. The default value is `nil.`
    ///
    /// - Returns: `True` if the child module has been pushed; otherwise, `false`.
    @discardableResult
    public final func pushChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard isActive else {
            log("Couldn't push the \(childName) child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let module = _module else {
            log("Couldn't push the \(childName) child module because this router didn't integrated into any module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let navigationController = navigationController ?? sharedNavigationController else {
            log("Couldn't push the \(childName) child module because this router didn't have any navigation controller",
                category: .moduleRouting, level: .error)
            return false
        }
        guard module.invokeChild(byName: childName), let child = module.router(of: .child(childName)) else {
            log("Couldn't push the \(childName) child module because it wasn't be invoked",
                category: .moduleRouting, level: .error)
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
    /// You can select a child module only when this module has a tab bar controller.
    ///
    /// In order to specify tab modules, you should override the `setup()` method of the module to which this router belongs
    /// and embed specifc modules:
    ///
    ///     final class MainModule: RAModule {
    ///
    ///         override func setup() -> Void {
    ///             embedChildModule(byName: "Feed")
    ///             embedChildModule(byName: "Messages")
    ///             embedChildModule(byName: "Settings")
    ///         }
    ///
    ///     }
    ///
    /// And then add specific tab modules from them (if you don't call these methods below then they are considered as tabs by default):
    ///
    ///     final class MainRouter: RARouter {
    ///
    ///         override func setup() -> Void {
    ///             addTabModule(byName: "Feed")
    ///             addTabModule(byName: "Messages")
    ///             addTabModule(byName: "Settings")
    ///         }
    ///
    ///     }
    ///
    /// - Parameter childName: The associated name of a module to be selected.
    /// - Parameter completion: The block to execute after the selecting finishes.
    /// This block has no return value and takes no parameters. The default value is `true.`
    ///
    /// - Returns: `True` if the child module has been selected; otherwise, `false`.
    @discardableResult
    public final func selectChildModule(byName childName: String, completion: (() -> Void)? = nil) -> Bool {
        guard isActive else {
            log("Couldn't push the \(childName) child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let module = _module else {
            log("Couldn't push the \(childName) child module because this router didn't integrated into any module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let tabBarController else {
            log("Couldn't select the \(childName) child module because this module didn't have a tab bar controller",
                category: .moduleRouting, level: .error)
            return false
        }
        guard childName != module.name else { return true }
        guard let tabIndex = namesOfTabModules.firstIndex(of: childName) else {
            log("Couldn't select the \(childName) child module because it wasn't a tab",
                category: .moduleRouting, level: .error)
            return false
        }
        guard module.invokeChild(byName: childName) else {
            // Most likely, the embedded child module is already loaded and started, but just in case we check it
            log("Couldn't select the \(childName) child module because it wasn't be invoked",
                category: .moduleRouting, level: .error)
            return false
        }
        tabBarController.selectViewController(withIndex: tabIndex, completion: completion)
        return true
    }
    
    
    // MARK: - Tab Bar Controller
    
    /// Setups a tab bar controller by setting view controllers of embedded child modules.
    internal final func setupTabBarController() -> Void {
        let childNames: [String]
        guard let tabBarController else { return }
        guard isInactive else {
            log("Couldn't setup a tab bar controller because this router was already active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't setup a tab bar controller because this didn't have any module",
                category: .moduleRouting, level: .error)
            return
        }
        if namesOfChildrenThatShouldBeTabs.isEmpty {
            childNames = module.namesOfEmbeddedChildren
        } else {
            childNames = namesOfChildrenThatShouldBeTabs
        }
        var childViewControllers = [UIViewController]()
        for childName in childNames {
            if let child = module.router(of: .child(childName)),
               let childViewController = child.viewController {
                childViewControllers.append(childViewController)
                namesOfTabModules.append(childName)
                child.transition = .selected
            } else {
                log("Couldn't add the `\(childName)` child module to a tab bar because it didn't have a view controller",
                    category: .moduleRouting, level: .error)
            }
        }
        tabBarController.setViewControllers(childViewControllers, animated: false)
    }
    
    /// Adds a specific module to tab modules by its associated name.
    ///
    /// It's used for a tab bar module. For example:
    ///
    ///     override func setup() -> Void {
    ///         addTabModule(byName: "Feed")
    ///         addTabModule(byName: "Messages")
    ///         addTabModule(byName: "Settings")
    ///     }
    ///
    /// - Important: The given name should match the corresponding name of the embedded child specified in the module.
    /// If you want that all embedded modules are considered tabs, then do not call this method,
    /// because embedded modules are considered tabs by default.
    ///
    /// - Note: The tab child module becomes built and loaded only during the loading of this module.
    /// That is, this method should be called in the `setup()` method.
    ///
    /// - Returns: `True` if the child added to tab modules; otherwise, `false`.
    @discardableResult
    public final func addTabModule(byName childName: String) -> Bool {
        guard isInactive else {
            log("Couldn't add the `\(childName)` tab because this router was already active",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let module = _module else {
            log("Couldn't add the `\(childName)` tab because this router didn't have any module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard module.namesOfEmbeddedChildren.contains(childName) else {
            log("Couldn't add the `\(childName)` tab because this module wasn't embedded",
                category: .moduleRouting, level: .error)
            return false
        }
        guard namesOfChildrenThatShouldBeTabs.contains(childName) == false else {
            log("Couldn't add the `\(childName)` tab twice",
                category: .moduleRouting, level: .warning)
            return false
        }
        namesOfChildrenThatShouldBeTabs.append(childName)
        return false
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this router before it starts working.
    ///
    /// This method is called when the module into which this router integrated is assembled but not yet loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    ///
    /// Most ofter you use this method in the following way:
    ///
    ///     override func setup() -> Void {
    ///         addTabModule(byName: "Feed")
    ///         addTabModule(byName: "Messages")
    ///         addTabModule(byName: "Settings")
    ///     }
    ///
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
