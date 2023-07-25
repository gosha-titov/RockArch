import Foundation

// Implementation notes
// ====================
//
// During the initialization/deinitialization of the component, it calls the `register(_:)`/`release(_:)` methods.
// So, it starts/stops being tracked by the leak detector.
//
// In order to detect memory leaks, the `detectMemoryLeaks()` method is called.
// This method compares the tracked components and components that are in the module tree.
// Therefore, components that are no longer in this tree are considered as memory leaks.
//
// There is a possibility that the detection method may be called a moment before the deinitialization of a component.
// That is, this component is considered as a memory leak for a short time.

/// The leak detector that monitors the deallocation of specific objects to avoid memory leaks.
///
/// It's often used during development to find memory leaks because of strong reference cycles.
/// But the detection does not happen automatically, that is, you need to manually call the corresponding method:
///
///     RALeakDetector.detectMemoryLeaks()
///
/// You can set a time interval for automatic calling the above detect method:
///
///     // Create and set new timer
///     RALeakDetector.addTimer(withInterval: 60.0)
///
///     // Remove the current timer
///     RALeakDetector.removeTimer()
///
public final class RALeakDetector: RAAnyObject {
    
    /// The singleton leak detector instance.
    public static let shared = RALeakDetector()

    
    // MARK: - Gerenal Info
    
    /// A string associated with the name of this leak detector.
    ///
    /// This property has the "Shared" value.
    public let name = "Shared"
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "LeakDetector" value.
    public let type = "LeakDetector"
    
    /// The state that describes the leak detector at a particular time.
    public private(set) var state: State = .observing
    
    
    // MARK: Private properties
    
    /// The default serial queue in which tracking performs.
    private let queue = DispatchQueue(label: "com.rockarch.leakdetector-shared", qos: .background)
    
    /// Objects that are currently being tracked.
    private var trackedObjects = [RAWeakObject]()
    
    
    // MARK: - Observing
    
    /// Registers the given object by adding it to the tracked ones.
    internal static func register(_ object: RAAnyObject) -> Void {
        shared.register(object)
    }
    
    /// Releases the given object by removing it from the tracked ones.
    internal static func release(_ object: RAAnyObject) -> Void {
        shared.release(object)
    }
    
    /// Registers the given object by adding it to the tracked ones.
    /// - Note: Should be called only during object initialization.
    private func register(_ object: RAAnyObject) -> Void {
        queue.async {
            self.removeEmptyObjects()
            if self.checkUniqueness(of: object) {
                self.beginTracking(object)
            }
        }
    }
    
    /// Releases the given object by removing it from the tracked ones.
    /// - Note: Should be called only during object deinitialization.
    private func release(_ object: RAAnyObject) -> Void {
        queue.async {
            self.removeEmptyObjects()
            self.remove(object)
        }
    }
    
    /// Begins tracking the given object.
    private func beginTracking(_ object: RAAnyObject) -> Void {
        let weakObject = RAWeakObject(reflecting: object)
        trackedObjects.append(weakObject)
    }
    
    /// Checks for the presence of the given object.
    /// - Returns: `True` if the given object is unique; otherwise, `false`.
    private func checkUniqueness(of object: RAAnyObject) -> Bool {
        return !trackedObjects.contains { $0.reference === object }
    }
    
    /// Removes tracked objects that have `nil` references.
    private func removeEmptyObjects() -> Void {
        trackedObjects = trackedObjects.filter { $0.reference.hasValue }
    }
    
    private func remove(_ object: RAAnyObject) -> Void {
        trackedObjects = trackedObjects.filter { $0.reference !== object}
    }
    
    
    // MARK: - Detecting
    
    internal static func detectMemoryLeaks() -> Void {
        shared.detectMemoryLeaks()
    }
    
    private func detectMemoryLeaks() -> Void {
        state = .detecting
        removeEmptyObjects()
    }
    
    
    // MARK: - Init
    
    /// Creates a leak detector instance.
    private init() {}
    
}


extension RALeakDetector {
    
    /// A state that describes the leak detector at a particular time.
    public enum State {
        
        /// The state in which the leak detector is currently observing the creation of components.
        case observing
        
        /// The state in which the leak detector is currently detecting memory leaks.
        case detecting
        
    }
    
}
