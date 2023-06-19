import UIKit

public protocol RAView: RAComponent, RAIntegratable where Self: UIViewController {}

extension RAView {
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "View" value.
    public var type: String {
        return "View"
    }
    
    /// Setups this view before it starts working.
    ///
    /// This method is called when the module into which this view integrated is loaded into memory and assembled.
    /// You define a new implementation for this method to perform additional initialization on your private properties.
    public func setup() {}
    
    /// Cleans this view after it stops working.
    ///
    /// This method is called when the module into which this view integrated is about to be unloaded from memory and disassembled.
    /// You define a new implementation for this method to clean your properties.
    public func clean() {}
    
    /// Performs internal setup for this view before it starts working.
    ///
    /// Only the module into which this view integrated should call this method when it is loaded into memory and assembled.
    /// - Note: The module should not call the `setup()` method directly, so it calls this internal `_setup()` method.
    internal func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Performs internal cleaning for this view after it stops working.
    ///
    /// Only the module into which this view integrated should call this method when it is about to be unloaded from memory and disassembled.
    /// - Note: The module should not call the `clean()` method directly, so it calls this internal `_clean()` method.
    internal func _clean() -> Void {
        clean() // Should be called first
    }
    
}
