/// A component that is a part of a module.
///
/// The `RAInteractor`, `RARouter`, `RAPresenter` and `RABuilder` objects conforms to this protocol.
/// These components have the same states and names as the modules to that they belong to.
/// - Note: The `module` property should be weak to avoid memory leaks.
public protocol RAComponentIntegratedIntoModule: RAComponent {
    
    /// A module to that this component belongs.
    /*weak*/ var module: RAModule? { get set }
    
}

public extension RAComponentIntegratedIntoModule {
    
    var state: RAComponentState {
        return module?.state ?? .inactive
    }
    
    var name: String {
        return module?.name ?? "Unowned"
    }
    
}


/// A single responsibility component that is a part of the architecture.
///
/// The `RAComponent` protocol is a basis of all key components, such as the `RAModule`, `RAInteractor`, `RARouter`, `RAPresenter`,
/// `RAView` and `RABuilder` objects. They constitute the backbone of the application architecture.
public protocol RAComponent: RAObject, RASimplifiedLoggable {
    
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
