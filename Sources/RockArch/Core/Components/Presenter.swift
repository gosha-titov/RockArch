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
    
    /// The view controller of the module.
    public let viewController: UIViewController
    
    /// A boolean value that indicates whether the view controller is a navigation controller.
    public final var hasNavigationController: Bool {
        return viewController is UINavigationController
    }
    
    /// A boolean value that indicates whether the view controller is a tab bar controller.
    public final var hasTabBarController: Bool {
        return viewController is UITabBarController
    }
    
    /// The view controller as a navigation controller, or `nil`.
    public final var navigationController: UINavigationController? {
        return viewController as? UINavigationController
    }
    
    /// The view controller as a tab bar controller, or `nil`.
    public final var tabBarController: UITabBarController? {
        return viewController as? UITabBarController
    }
    
    
    // MARK: Internal Properties
    
    /// An internal module to that this view belongs.
    internal weak var _module: RAModule?
    
    /// An internal interactor that is set by a module.
    internal weak var _interactor: RAAbstractInteractor?
    
    
    // MARK: - Internal Init
    
    /// Creates an abstract presenter instance with a specific view controller.
    internal init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
}
