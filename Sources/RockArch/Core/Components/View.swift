import UIKit

open class RAView: RAAbstractView {
    
}

open class RAAbstractView: UIViewController, RAComponent, RAModuleBelongable {
    
    // MARK: - Public Properties
    
    /// A name of the module to that this view belongs.
    public final var name: String {
        return _module?.name ?? "Unnamed"
    }
    
    /// A textual representation of the type of this view.
    public let type: String = "View"
    
    /// The current state of the module to that this view belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    
    // MARK: - Internal Properties
    
    /// An internal module to that this view belongs.
    internal weak var _module: RAModule?
    
    /// An internal interactor that is set by a module.
    internal weak var _interactor: RAAbstractInteractor?
    
}
