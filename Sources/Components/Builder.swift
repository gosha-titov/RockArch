open class RABuilder: RAComponent, RAIntegratable {
    
    /// A module into which this builder is integrated.
    public weak var module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Builder" value.
    public let type: String = "Builder"
    
    /// Setups this builder before it starts working.
    ///
    /// This method is called when the module into which this builder integrated is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this builder after it stops working.
    ///
    /// This method is called when the module into which this builder integrated is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Creates a builder instance.
    public init() {}
    
}
