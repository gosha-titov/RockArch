/// A single responsibility component that is a part of the architecture.
///
/// The `RAComponent` protocol is a basis of all key components, such as the `RAModule`, `RAInteractor`, `RARouter`,
/// `RAView` and `RABuilder` objects. They constitute the backbone of the application architecture.
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
