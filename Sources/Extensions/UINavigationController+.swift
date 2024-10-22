import UIKit

internal extension UINavigationController {
    
    /// Pushes a view controller onto the receiver’s stack and updates the display.
    @inlinable
    func push(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?) -> Void {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    /// Pops the top view controller from the navigation stack and updates the display.
    @discardableResult @inlinable
    func popViewController(animated: Bool = true, completion: (() -> Void)?) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let viewController = popViewController(animated: animated)
        CATransaction.commit()
        return viewController
    }
    
    /// Pops view controllers until the specified view controller is at the top of the navigation stack.
    @discardableResult @inlinable
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) -> [UIViewController]? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let viewControllers = popToViewController(viewController, animated: animated)
        CATransaction.commit()
        return viewControllers
    }
    
    /// Pops all the view controllers on the stack except the root view controller and updates the display.
    @discardableResult @inlinable
    func popToRootViewController(animated: Bool = true, completion: (() -> Void)?) -> [UIViewController]? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let viewControllers = popToRootViewController(animated: animated)
        CATransaction.commit()
        return viewControllers
    }
    
}
