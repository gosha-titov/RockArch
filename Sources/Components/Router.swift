open class RARouter: RAComponent, RAIntegratable {
    
    /// A module into which this router is integrated.
    public weak var module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Router" value.
    public let type: String = "Router"
    
    /// Setups this router before it starts working.
    ///
    /// This method is called when the module into which this router integrated is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this router after it stops working.
    ///
    /// This method is called when the module into which this router integrated is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Performs internal setup for this router before it starts working.
    ///
    /// Only the module into which this router integrated should call this method when it is loaded into memory and assembled.
    /// - Note: The module should not call the `setup()` method directly, so it calls this internal `_setup()` method.
    internal final func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Performs internal cleaning for this router after it stops working.
    ///
    /// Only the module into which this router integrated should call this method when it is about to be unloaded from memory and disassembled.
    /// - Note: The module should not call the `clean()` method directly, so it calls this internal `_clean()` method.
    internal final func _clean() -> Void {
        clean() // Should be called first
    }
    
    
    /// Creates a router instance.
    public init() {}
    
}



internal final class RAStubRouter: RARouter {}
