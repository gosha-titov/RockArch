open class RARouter: RAComponent, RAModuleBelongable {
    
    // MARK: - Properties
    
    /// A name of the module to that this router belongs.
    public final var name: String {
        return _module?.name ?? "Unnamed"
    }
    
    /// A textual representation of the type of this router.
    public let type: String = "Router"
    
    /// The current state of the module to that this router belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    /// An internal module to that this router belongs.
    internal weak var _module: RAModule?
    
    
    // MARK: - Public Init
    
    /// Creates a router instance.
    public init() {
        RALeakDetector.register(self)
    }
    
}


/// A router that is marked as empty.
internal final class RAEmptyRouter: RARouter, RAEmpty {}
