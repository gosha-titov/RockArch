open class RARouter: RAComponentIntegratedIntoModule {
    
    // MARK: - Properties
    
    /// A module to that this router belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Router" value.
    public let type: String = "Router"
    
    
    // MARK: - Lifecycle
    
    /// Setups this router.
    ///
    /// This method is called when the module to which this router belongs is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this router.
    ///
    /// This method is called when the module to which this router belongs is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    /// Called when the module is loaded into memory and assembled.
    internal final func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal final func _clean() -> Void {
        clean()
    }
    
    
    // MARK: - Public Init
    
    /// Creates a router instance.
    public init() {}
    
}


/// A router that is marked as empty.
internal final class RAEmptyRouter: RARouter, RAEmpty {}
