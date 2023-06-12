import Foundation

/// The leak detector that monitors the deallocation of certain objects to avoid memory leaks.
public final class RALeakDetector: RAAnyObject {
    
    /// The singleton leak detector instance.
    public static let shared = RALeakDetector()
    
    /// A string associated with the name of this leak detector.
    ///
    /// This property has the "Shared" value.
    public let name = "Shared"
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "LeakDetector" value.
    public let type = "LeakDetector"
    
    /// The default serial queue in which tracking performs.
    private let queue = DispatchQueue(label: "com.rockarch.leakdetector-shared", qos: .background)
    
    /// Objects that are currently being tracked.
    private var trackedObjects = [RAWeakObject]()
    
    /// Registers the given object by adding it to the tracked ones.
    private func register(_ object: RAAnyObject) -> Void {
        queue.async {
            self.removeEmptyObjects()
            if self.checkUniqueness(of: object) {
                self.beginTracking(object)
            }
        }
    }
    
    /// Begins tracking the given object.
    private func beginTracking(_ object: RAAnyObject) -> Void {
        let weakObject = RAWeakObject(reflecting: object)
        trackedObjects.append(weakObject)
    }
    
    /// Checks for the presence of the given object.
    /// - Returns: `True` if the given object is unique; otherwise, `false`.
    private func checkUniqueness(of checkedObject: RAAnyObject) -> Bool {
        return !trackedObjects.contains { $0.reference === checkedObject }
    }
    
    /// Removes tracked objects that have `nil` references.
    private func removeEmptyObjects() -> Void {
        trackedObjects = trackedObjects.filter { $0.reference.hasValue }
    }
    
    /// Creates a leak detector instance.
    private init() {}
    
}
