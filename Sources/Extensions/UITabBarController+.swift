import UIKit

internal extension UITabBarController {
    
    /// Selects a view controller by the given index.
    @inlinable func selectViewController(withIndex tabIndex: Int, completion: (() -> Void)?) -> Void {
        selectedIndex = tabIndex
        completion?()
    }
    
}
