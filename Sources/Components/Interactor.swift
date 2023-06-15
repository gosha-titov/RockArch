open class RAInteractor: RAComponent, RAIntegratable {
    
    /// A module into which this interactor is integrated.
    public weak var module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Interactor" value.
    public let type: String = "Interactor"
    
    /// Setups this interactor before it starts working.
    ///
    /// This method is called when the module into which this interactor integrated is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this interactor after it stops working.
    ///
    /// This method is called when the module into which this interactor integrated is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Creates an interactor instance.
    public init() {}
    
}
