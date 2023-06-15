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
    
}
