/// A type that can be integrated into a module.
///
/// The `RAIntegratable` protocol has a `module` property to which this component integrated into.
/// Thereby, the integrated component reflects the module by having the same name and type as the module.
/// The `RAInteractor`, `RARouter`, `RAPresenter` and `RABuilder` components conforms to this protocol.
/// - Note: The `module` property should be weak to avoid memory leaks.
public protocol RAIntegratable where Self: RAComponent {
    
    /// A module to that this component is integrated into.
    /*weak*/ var module: RAModule? { get set }
    
}

public extension RAIntegratable {
        
    /// A string associated with the name of this component.
    ///
    /// This property has the same name as the name of the module to which this component is integrated into; otherwise, "Unowned".
    /// It's the default implementation of this property.
    var name: String {
        return module?.name ?? "Unowned"
    }
    
    /// The current state of this component.
    ///
    /// This property has the same state as the state of the module to which this component is integrated into; otherwise, `.inactive`.
    /// It's the default implementation of this property.
    var state: RAComponentState {
        return module?.state ?? .inactive
    }
    
}



/// A single responsibility component that is a part of the architecture.
///
/// The `RAComponent` protocol is a basis of all key components, such as the `RAModule`, `RAInteractor`, `RARouter`,
/// `RABuilder` and `RAView` objects. They constitute the backbone of the application architecture.
///
/// This protocol has the `state` property and two lifecycle methods: `setup()` and `clean()`.
public protocol RAComponent: RAAnyObject, RALoggable {
    
    /// The current state of this component.
    var state: RAComponentState { get }
    
    /// Setups this component after it is loaded into memory.
    func setup()
    
    /// Cleans this component when it is about to be unloaded from memory.
    func clean()
    
}


/// A state that describes the component at a particular time.
public enum RAComponentState {
    
    /// The state in which the component is currently running
    case active
    
    /// The state in which the component is suspended for a while.
    case suspended
    
    /// The state in which the component doesn't perform any work.
    case inactive
    
}
