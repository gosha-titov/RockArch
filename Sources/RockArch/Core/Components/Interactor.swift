open class RAInteractor: RAAbstractInteractor {
    
}


open class RAAbstractInteractor: RAComponent, RAModuleBelongable {
    
    // MARK: - Public Properties
    
    /// A name of the module to that this interactor belongs.
    public final var name: String {
        return _module?.name ?? "Unnamed"
    }
    
    /// A textual representation of the type of this interactor.
    public let type: String = "Interactor"
    
    /// The current state of the module to that this interactor belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    
    // MARK: Internal Properties
    
    /// An internal module to that this interactor belongs.
    internal weak var _module: RAModule?
    
    /// An internal router that is set by a module.
    internal weak var _router: RARouter?
    
    /// An internal view that is set by a module.
    internal weak var _view: RAAbstractView?
    
}


internal final class RAEmptyInteractor: RAAbstractInteractor, RAEmpty {}
