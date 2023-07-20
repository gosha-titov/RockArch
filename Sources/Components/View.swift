import UIKit

public protocol RAView: RAComponent, RAIntegratable where Self: UIViewController {}

extension RAView {
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "View" value.
    public var type: String {
        return "View"
    }
    
    /// A module into which this view is integrated.
    public var module: RAModuleInterface? { _module }
    
    /// An internal module of this view.
    internal var _module: RAModule? {
        get {
            let storage = RAWeakModuleStorage.shared
            return storage[debugDescription]
        }
        set {
            let storage = RAWeakModuleStorage.shared
            storage[debugDescription] = newValue
        }
    }
    
    /// An internal interactor of this module.
    internal var _interactor: RAInteractor? {
        get {
            let storage = RAWeakInteractorStorage.shared
            return storage[debugDescription]
        }
        set {
            let storage = RAWeakInteractorStorage.shared
            storage[debugDescription] = newValue
        }
    }
    
    /// Setups this view before it starts working.
    ///
    /// This method is called when the module into which this view integratedis assembled but not yet loaded into the module tree.
    /// You define a new implementation for this method to perform additional initialization on your private properties.
    public func setup() -> Void {}
    
    /// Cleans this view after it stops working.
    ///
    /// This method is called when the module into which this view integrated is about to be unloaded from the module tree and disassembled.
    /// You define a new implementation for this method to clean your properties.
    public func clean() -> Void {}
    
}
