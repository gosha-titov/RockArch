open class RAModule: RAComponent {
    
    /// A string associated with the name of this module.
    public let name: String
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Module" value.
    public let type: String = "Module"
    
    /// The current state of this module.
    public private(set) var state: RAComponentState = .inactive
    
    /// Setups this module.
    ///
    /// This method is called when this module is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this module.
    ///
    /// This method is called when this module is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Creates a named module instance.
    public init(name: String) {
        self.name = name
    }
    
}
