/// A builder that can build child modules by their associated names.
open class RABuilder: RAComponent {
    
    // MARK: - Properties
    
    /// A name of the module to that this router belongs.
    public final var name: String {
        return _module?.name ?? "Unnamed"
    }
    
    /// A textual representation of the type of this router.
    public let type: String = "Builder"
    
    /// The current state of the module to that this router belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    /// A logger that logs messages.
    public final var logger: RALogger? {
        return _module?.logger
    }
    
    /// An internal module to that this router belongs.
    internal weak var _module: RAModule?
    
    
    // MARK: - Public Init
    
    /// Creates a builder.
    public init() {}
    
}
