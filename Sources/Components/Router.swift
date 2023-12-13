import UIKit

// Implementation notes
// ====================
//
// Embedded child modules are already built, loaded and automatically started/stoped.
// That is, there's no need to call the `invokeChildModule(byName:animation:)` method.

/// A router that is responsible for the hierarchy of modules: showing and hiding child modules, completing the module.
///
/// The `RARouter` class defines the shared behavior that’s common to all routers.
/// You almost always subclass the `RARouter` but you make minor changes,
/// since each router has already defined all transitions between modules.
///
/// The router has a lifecycle consisting of the `setup()` and `clean()` methods,
/// which are called when the module is attached to or detached from the module tree.
/// You can override these to perform additional initialization on your properties and, accordingly, to clean them.
///
/// If the module has embedded children, you can access them by using the `embeddedViewControllers` property and
/// by redefining the `loadEmbeddedViewControllers()` method to make sure they really exist.
/// It's used if you want to custom display these child controllers.
///
/// - Note: Each component can log messages by calling the `log(_:category:level:)` method.
/// These messages are handled by the current black box with its loggers.
///
open class RARouter: RAComponent, RAIntegratable, RARouterInterface {
    
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
    public internal(set) var currentTransition: Transition?
    
    /// The transition that indicates how preferably to show the module.
    public var preferredTransition: Transition?
    
    /// The names of the child modules that are tabs of the tab bar controller.
    public private(set) var namesOfTabModules = [String]()
    
    /// The array of names of child modules that should be added to the tab bar.
    private var namesOfChildrenThatShouldBeTabs = [String]()
    
    /// A router of a parent module.
    private var parent: RARouter? {
        return _module?.parent?.router
    }
    
    /// The dictionary that stores routers of embedded child modules by their names.
    private var embeddedChildren: [String: RARouter] {
        guard let module = _module else { return [:] }
        var dict = [String: RARouter]()
        module.embeddedChildren.forEach { dict[$0.key] = $0.value.router }
        return dict
    }
    
    /// The dictionary that stores view controllers of embedded child modules by their names.
    public final var embeddedViewControllers: [String: UIViewController] {
        guard let module = _module else { return [:] }
        var dict = [String: UIViewController]()
        module.embeddedChildren.forEach { dict[$0.key] = $0.value.view }
        return dict
    }
    
    
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
    
    /// A navigation controllers that pushed a view controller of this module.
    public final var sharedNavigationController: UINavigationController? {
        return sharedNavigationRouter?.navigationController
    }
    
    /// A router with a navigation controllers that pushed a view controller of this module.
    internal weak var sharedNavigationRouter: RARouter?
    
    /// A name of child module that was pushed by this module.
    public private(set) var nameOfpushedChildModule: String?
    
    /// A first view controller found in this flow.
    public final var firstViewController: UIViewController? {
        let parent = _module?.router(of: .parent)
        return viewController ?? parent?.firstViewController
    }
    
    
    // MARK: - Routing
    
    /// Completes this module by hiding it from the screen.
    ///
    /// This method represents the hiding, stopping and unloading this module.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is hidden.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func complete(animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't complete the module this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let parent, let module = _module else {
            log("Couldn't complete the module because it didn't have a parent module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let _ = currentTransition else {
            log("Couldn't complete the module because it wasn't shown",
                category: .moduleRouting, level: .error)
            return
        }
        parent.hideChildModule(byName: module.name, animated: animated, completion: completion)
    }
    
    /// Show a view controller of a specific child module by using its preferred transition.
    ///
    /// This method represents the building, loading, starting and showing a child module.
    /// - Parameter childName: The associated name of a module to be shown.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the showing finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func showChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't show the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't show the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard module.loadChild(byName: childName), let child = module.router(of: .child(childName)) else {
            log("Couldn't show the `\(childName)` child module because it wasn't loaded",
                category: .moduleRouting, level: .error)
            return
        }
        guard let childPreferredTransition = child.preferredTransition else {
            log("Couldn't show the `\(childName)` child module because it had no set preferred transition",
                category: .moduleRouting, level: .error)
            return
        }
        switch childPreferredTransition {
        case .present: presentChildModule(byName: childName, animated: animated, completion: completion)
        case .push:    pushChildModule   (byName: childName, animated: animated, completion: completion)
        case .select:  selectChildModule (byName: childName,                     completion: completion)
        }
    }
    
    /// Hides a view controller of a specifc child module in the reverse way to how it was shown.
    ///
    /// This method represents the hiding, stopping and unloading a child module.
    /// - Parameter childName: The associated name of a module to be dismissed.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is dismissed.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func hideChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't hide the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't hide the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let child = module.router(of: .child(childName)) else {
            log("Couldn't hide the `\(childName)` uknown child module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let childCurrentTransition = child.currentTransition else {
            log("Couldn't hide the `\(childName)` child module becuase it wasn't shown",
                category: .moduleRouting, level: .error)
            return
        }
        switch childCurrentTransition {
        case .present: dismissChildModule(byName: childName, animated: animated, completion: completion)
        case .push:    popChildModule    (byName: childName, animated: animated, completion: completion)
        case .select:
            log("Couldn't hide the `\(childName)` embedded child module",
                category: .moduleRouting, level: .error)
            return
        }
    }
    
    
    // MARK: Presenting and Dismissing
    
    /// Presents a view controller of a specific child module modally.
    ///
    /// This method represents the building, loading, starting and presenting a child module.
    /// - Parameter childName: The associated name of a module to be present.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the presentation finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func presentChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't present the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't present the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let viewControllerThatPresents = firstViewController else {
            log("Couldn't present the `\(childName)` child module because this flow didn't have any view controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard module.loadChild(byName: childName), let child = module.router(of: .child(childName)) else {
            log("Couldn't present the `\(childName)` child module because it wasn't loaded",
                category: .moduleRouting, level: .error)
            return
        }
        let presentChildViewController: RADefaultAnimation = { childViewController in
            viewControllerThatPresents.present(childViewController, animated: animated, completion: completion)
        }
        guard module.invokeChild(byName: childName, animation: presentChildViewController) else {
            log("Couldn't present the `\(childName)` child module because it wasn't invoked",
                category: .moduleRouting, level: .error)
            return
        }
        child.currentTransition = .present
    }
    
    /// Dismesses a view controller of a specific child module that was presented modally.
    ///
    /// This method represents the dismissing, stopping and unloading a child module.
    /// You can dismiss a child module only if its view controller was presented modally.
    /// - Parameter childName: The associated name of a module to be dismissed.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is dismissed.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func dismissChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't dismiss the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't dismiss the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let child = module.router(of: .child(childName)) else {
            log("Couldn't dismiss the `\(childName)` unknown child module",
                category: .moduleRouting, level: .error)
            return
        }
        guard child.currentTransition == .present else {
            log("Couldn't dismiss the `\(childName)` child module because it wan't presented",
                category: .moduleRouting, level: .error)
            return
        }
        let dismissChildViewController: RADefaultAnimation = { childViewController in
            childViewController.dismiss(animated: animated, completion: completion)
        }
        guard module.revokeChild(byName: childName, animation: dismissChildViewController) else {
            log("Couldn't dismiss the `\(childName)` child module because it wasn't revoked",
                category: .moduleRouting, level: .error)
            return
        }
        child.currentTransition = nil
    }
    
    
    // MARK: Pushing and Popping
    
    /// Pushes a view controller of a specific child module onto a navigation stack.
    ///
    /// This method represents the building, loading, starting and pushing a child module.
    /// You can push a child module only if this module is pushed by another navigation controller.
    /// - Note: When the **A** module pushes the **B** child module, **A** shares a navigation controller to **B**.
    /// That is, **B** is also able to push its child modules.
    /// - Parameter childName: The associated name of a module to be pushed.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the pushing finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func pushChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't push the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't push the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard navigationController.isNil else {
            log("Couldn't push the `\(childName)` child module because this routred already set a root view controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard let sharedNavigationRouter, let sharedNavigationController = sharedNavigationRouter.navigationController else {
            log("Couldn't push the `\(childName)` child module because this router didn't have any navigation controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard sharedNavigationController.topViewController === viewController else {
            log("Couldn't push the `\(childName)` child module because this module wasn't at the top of the navigation stack",
                category: .moduleRouting, level: .error)
            return
        }
        guard nameOfpushedChildModule.isNil else {
            log("Couldn't push the `\(childName)` child module because this module already pushed another child module",
                category: .moduleRouting, level: .error)
            return
        }
        guard module.loadChild(byName: childName), let child = module.router(of: .child(childName)) else {
            log("Couldn't push the `\(childName)` child module because it wasn't loaded",
                category: .moduleRouting, level: .error)
            return
        }
        let pushChildViewController: RADefaultAnimation = { childViewController in
            sharedNavigationController.push(childViewController, animated: animated, completion: completion)
        }
        guard module.invokeChild(byName: childName, animation: pushChildViewController) else {
            log("Couldn't push the `\(childName)` child module because it wasn't invoked",
                category: .moduleRouting, level: .error)
            return
        }
        nameOfpushedChildModule = childName
        child.sharedNavigationRouter = sharedNavigationRouter
        child.currentTransition = .push
    }
    
    /// Pops view controllers until the view controller of this module is at the top of the navigation stack.
    ///
    /// This method represents the popping, stopping and unloading child modules on the navigation stack.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controllers are popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func popToThisModule(animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        if let childName = nameOfpushedChildModule {
            popChildModule(byName: childName, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    /// Pops a view controller of a specific child module from the navigation stack.
    ///
    /// This method represents the popping, stopping and unloading a child module on the navigation stack.
    /// - Parameter childName: The associated name of a module to be popped.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func popChildModule(byName childName: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't pop the `\(childName)` child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't pop the `\(childName)` child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let child = module.router(of: .child(childName)) else {
            log("Couldn't pop the \(childName) unknown child module",
                category: .moduleRouting, level: .error)
            return
        }
        guard child.currentTransition == .push else {
            log("Couldn't pop the `\(childName)` child module because it wasn't pushed",
                category: .moduleRouting, level: .error)
            return
        }
        guard nameOfpushedChildModule == childName else {
            log("Couldn't pop the `\(childName)` child module because this router didn't push it",
                category: .moduleRouting, level: .error)
            return
        }
        guard navigationController.isNil else {
            log("Couldn't pop the `\(childName)` child module because it was the root view controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard let sharedNavigationRouter, let sharedNavigationController = sharedNavigationRouter.navigationController else {
            log("Couldn't pop the `\(childName)` child module because this router didn't have any navigation controllers",
                category: .moduleRouting, level: .error)
            return
        }
        guard let viewController else {
            log("Couldn't pop the `\(childName)` child module because this router didn't have a view controller",
                category: .moduleRouting, level: .error)
            // It's just to unwrap the value
            return
        }
        let popChildViewController: RADefaultAnimation = { _ in
            sharedNavigationController.popToViewController(viewController, animated: animated, completion: completion)
        }
        guard module.revokeChild(byName: childName, animation: popChildViewController) else {
            log("Couldn't pop the `\(childName)` child module because it wasn't revoked",
                category: .moduleRouting, level: .error)
            return
        }
        child.sharedNavigationRouter = nil
        child.currentTransition = nil
        nameOfpushedChildModule = nil
    }
    
    /// Pops all modules on the stack except the root module.
    ///
    /// This method represents the popping, stopping and unloading all modules on the navigation stack except the root module.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controllers are popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func popToRootModule(animated: Bool, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't pop to the root module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        if let _ = navigationController {
            popToRootChildModule(animated: animated, completion: completion)
        } else {
            guard let sharedNavigationRouter else {
                log("Couldn't pop to the root module because this router had no navigation controller.",
                    category: .moduleRouting, level: .error)
                return
            }
            sharedNavigationRouter.popToRootChildModule(animated: animated, completion: completion)
        }
    }
    
    /// Pops all modules on the stack except the root child module.
    ///
    /// This method represents the popping, stopping and unloading all modules on the navigation stack except the root child module.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controllers are popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    internal final func popToRootChildModule(animated: Bool, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't pop to the root child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard let module = _module else {
            log("Couldn't pop to the root child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let _ = navigationController else {
            log("Couldn't pop to the root child module because this router didn't have a navigation controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard let childName = nameOfpushedChildModule else { // is always the root module
            log("Couldn't pop to the root child module because this router didn't push a root view controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard let child = module.router(of: .child(childName)) else {
            log("Couldn't pop to the `\(childName)` root child module",
                category: .moduleRouting, level: .error)
            return
        }
        child.popToThisModule(animated: animated, completion: completion)
    }
    
    
    // MARK: Selecting
    
    /// Selects a view controller of a specific child module.
    ///
    /// You can select an embedded child module only when this module has a tab bar controller.
    /// - Parameter childName: The associated name of an embedded module to be selected.
    /// - Parameter completion: The block to execute after the selecting finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    public final func selectChildModule(byName childName: String, completion: (() -> Void)? = nil) -> Void {
        guard isActive else {
            log("Couldn't push the \(childName) child module because this router wasn't active",
                category: .moduleRouting, level: .error)
            return
        }
        guard _module.hasValue else {
            log("Couldn't push the \(childName) child module because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return
        }
        guard let tabBarController else {
            log("Couldn't select the \(childName) child module because this module didn't have a tab bar controller",
                category: .moduleRouting, level: .error)
            return
        }
        guard let tabIndex = namesOfTabModules.firstIndex(of: childName) else {
            log("Couldn't select the \(childName) child module because it wasn't a tab",
                category: .moduleRouting, level: .error)
            return
        }
        // An embedded child module is already invoked
        tabBarController.selectViewController(withIndex: tabIndex, completion: completion)
    }
    
    
    // MARK: - Setuping Controllers
    
    /// Setups a tab bar controller by setting view controllers of embedded child modules.
    /// - Returns: `True` if the child view controller have been set; otherwise, `false`.
    internal final func setupTabBarController() -> Bool {
        guard let tabBarController else {
            log("Couldn't setup a tab bar controller because this router didn't have it",
                category: .moduleRouting, level: .error)
            return false
        }
        guard isInactive else {
            log("Couldn't setup a tab bar controller because this router was already active",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let module = _module else {
            log("Couldn't setup a tab bar controller because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard embeddedChildren.isEmpty == false else {
            log("Couldn't setup a tab bar controller because this router didn't have embedded children",
                category: .moduleRouting, level: .error)
            return false
        }
        let childNames = module.namesOfEmbeddedChildren
        var childViewControllers = [UIViewController]()
        for childName in childNames {
            if let child = embeddedChildren[childName],
               let childViewController = child.viewController {
                childViewControllers.append(childViewController)
                namesOfTabModules.append(childName)
                child.preferredTransition = .select
                child.currentTransition = .select
            } else {
                log("Couldn't add the `\(childName)` child module to a tab bar because it didn't have a view controller",
                    category: .moduleRouting, level: .error)
            }
        }
        tabBarController.setViewControllers(childViewControllers, animated: false)
        return true
    }
    
    /// Setups a navigation controller by setting the root view controller of an embedded child module.
    /// - Returns: `True` if the root view controller has been set; otherwise, `false`.
    internal final func setupNavigationController() -> Bool {
        guard let navigationController else {
            log("Couldn't setup a navigation controller because this router didn't have it",
                category: .moduleRouting, level: .error)
            return false
        }
        guard isInactive else {
            log("Couldn't setup a navigation controller because this router was already active",
                category: .moduleRouting, level: .error)
            return false
        }
        guard _module.hasValue else {
            log("Couldn't setup a navigation controller because this router didn't integrated into a module",
                category: .moduleRouting, level: .error)
            return false
        }
        let embeddedChildren = embeddedChildren
        guard embeddedChildren.count == 1, let child = embeddedChildren.first?.value else {
            log("Couldn't setup a navigation controller because the module didn't have exactly one embedded module",
                category: .moduleRouting, level: .error)
            return false
        }
        guard let childViewController = child.viewController else {
            log("Couldn't setup a navigation controller because it didn't have a view controller",
                category: .moduleRouting, level: .error)
            return false
        }
        navigationController.setViewControllers([childViewController], animated: false)
        child.sharedNavigationRouter = self
        child.currentTransition = .push
        nameOfpushedChildModule = child.name
        return true
    }
    
    /// Setups a navigation or a tab bar controller if it exists.
    internal final func setupContainerController() -> Bool {
        if navigationController.hasValue {
            return setupNavigationController()
        } else if tabBarController.hasValue {
            return setupTabBarController()
        }
        return true
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this router before it starts working.
    ///
    /// This method is called when the module into which this router integrated is assembled and loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    ///
    ///     override func setup() -> Void {
    ///         preferredTransition = .present
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
    
    /// Loads embedded view controllers of this module.
    ///
    /// This method is used when the module has embedded children, and you need to animate them in your own way.
    /// So you load the view controllers of these modules in the following way:
    ///
    ///     let messagesViewController: UIViewController!
    ///     let settingsViewController: UIViewController!
    ///
    ///     func loadEmbeddedViewControllers() -> Bool {
    ///         guard let messagesViewController = embeddedViewControllers["Messages"],
    ///               let settingsViewController = embeddedViewControllers["Settings"]
    ///         else { return false }
    ///         self.messagesViewController = messagesViewController
    ///         self.settingsViewController = settingsViewController
    ///         return true
    ///     }
    ///
    /// - Note: This method is called during the loading of the module, but before the `setup()` method of this router.
    /// - Returns: `True` if all the necessary view controllers have been loaded; otherwise, `false`.
    open func loadEmbeddedViewControllers() -> Bool {
        return true
    }
    
    
    // MARK: - Init and Deinit
    
    /// Creates a router instance.
    public init() {
        RALeakDetector.register(self)
    }
    
    deinit {
//        RALeakDetector.release(self)
    }
    
}



extension RARouter {
    
    public enum Transition {
        case present
        case push
        case select
    }
    
}



/// A communication interface between an interactor and a router.
public protocol RARouterInterface {
    
    /// Completes this module by hiding it from the screen.
    ///
    /// This method represents the hiding, stopping and unloading this module.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is hidden.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func complete(animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Show a view controller of a specific child module by using its preferred transition.
    ///
    /// This method represents the building, loading, starting and showing a child module.
    /// - Parameter childName: The associated name of a module to be shown.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the showing finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func showChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Hides a view controller of a specifc child module in the reverse way to how it was shown.
    ///
    /// This method represents the hiding, stopping and unloading a child module.
    /// - Parameter childName: The associated name of a module to be dismissed.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is dismissed.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func hideChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Presents a view controller of a specific child module modally.
    ///
    /// This method represents the building, loading, starting and presenting a child module.
    /// - Parameter childName: The associated name of a module to be present.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the presentation finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func presentChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Dismesses a view controller of a specific child module that was presented modally.
    ///
    /// This method represents the dismissing, stopping and unloading a child module.
    /// You can dismiss a child module only if its view controller was presented modally.
    /// - Parameter childName: The associated name of a module to be dismissed.
    /// - Parameter animated: Specify `true` to animate the transition, or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is dismissed.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func dismissChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Pushes a view controller of a specific child module onto a navigation stack.
    ///
    /// This method represents the building, loading, starting and pushing a child module.
    /// You can push a child module only if this module is pushed by another navigation controller.
    /// - Note: When the **A** module pushes the **B** child module, **A** shares a navigation controller to **B**.
    /// That is, **B** is also able to push its child modules.
    /// - Parameter childName: The associated name of a module to be pushed.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the pushing finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func pushChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Pops a view controller of a specific child module from the navigation stack.
    ///
    /// This method represents the popping, stopping and unloading a child module on the navigation stack.
    /// - Parameter childName: The associated name of a module to be popped.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controller is popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func popChildModule(byName childName: String, animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Pops view controllers until the view controller of this module is at the top of the navigation stack.
    ///
    /// This method represents the popping, stopping and unloading child modules on the navigation stack.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controllers are popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func popToThisModule(animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Pops all modules on the stack except the root module.
    ///
    /// This method represents the popping, stopping and unloading all modules on the navigation stack except the root module.
    /// - Parameter animated: Specify `true` to animate the transition or `false` if you do not want the transition to be animated.
    /// The default value is `true`.
    /// - Parameter completion: The block to execute after the view controllers are popped.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func popToRootModule(animated: Bool, completion: (() -> Void)?) -> Void
    
    /// Selects a view controller of a specific child module.
    ///
    /// You can select an embedded child module only when this module has a tab bar controller.
    /// - Parameter childName: The associated name of an embedded module to be selected.
    /// - Parameter completion: The block to execute after the selecting finishes.
    /// This block has no return value and takes no parameters. The default value is `nil`.
    func selectChildModule(byName childName: String, completion: (() -> Void)?) -> Void
    
}
