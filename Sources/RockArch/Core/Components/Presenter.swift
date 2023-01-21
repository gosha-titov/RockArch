import UIKit

open class RAAbstractPresenter: RAComponent {
    
    // MARK: - Public Properties
    
    /// A name of the module to that this view belongs.
    public final var name: String {
        return _module?.name ?? "Unowned"
    }
    
    /// The textual representation of the type of this view.
    public let type: String = "Presenter"
    
    /// The current state of the module to that this view belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    
    // MARK: Internal Properties
    
    /// An internal module to that this view belongs.
    internal weak var _module: RAModule?
    
    /// An internal interactor that is set by a module.
    internal weak var _interactor: RAAbstractInteractor?
    
    /// The view controller of the module.
    internal let viewController: UIViewController
    
    /// The view controller as a navigation controller, or `nil`.
    internal final var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    /// The view controller as a tab bar controller, or `nil`.
    internal final var tabBarController: UITabBarController? {
        return viewController as? UITabBarController
    }
    
    /// A boolean value that indicates whether the view controller is a navigation controller.
    internal final var hasNavigationController: Bool {
        return viewController is UINavigationController
    }
    
    /// A boolean value that indicates whether the view controller is a tab bar controller.
    internal final var hasTabBarController: Bool {
        return viewController is UITabBarController
    }
    
    
    // MARK: - Lifecycle
    
    /// Called when the module is loaded into memory.
    internal final func _setup() -> Void {
        let view = RAWrappedObject(name: name, type: "View", objectToWrap: viewController)
        RALeakDetector.register(view)
        setup()
    }
    
    /// Called when the module is about to be unloaded from memory.
    internal final func _clean() -> Void {
        clean()
    }
    
    /// Setups this presenter.
    ///
    /// This method is called when the module to which this presenter belongs is loaded into memory.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this presenter.
    ///
    /// This method is called when the module to which this presenter belongs is about to be unloaded from memory.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    
    // MARK: - Internal Init
    
    /// Creates an abstract presenter instance with a specific view controller.
    internal init(viewController: UIViewController) {
        self.viewController = viewController
        viewController._presenter = self
        RALeakDetector.register(self)
    }
    
}
