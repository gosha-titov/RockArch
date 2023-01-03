/// A single responsibility component that is a part of architecture.
///
/// The `RAComponent` protocol is a basis of all key components, such as the `RAModule` objects,
/// the `RAInteractor` objects, the `RARouter` objects, the `RAView` objects and the `RABuilder` objects.
/// They constitute the backbone of an application architecture.
public protocol RAComponent: RAObject, RALoggerHolder, RASimplifiedLoggable {
    
    /// The current state of this component.
    var state: RAComponentState { get }
    
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
