import Foundation

public final class RALeakDetector: RAObject {
    
    /// The singleton leak detector instance.
    public static let shared = RALeakDetector()
    
    /// Registers a specific object by adding it to the tracked ones.
    internal static func register(_ object: RAObject) -> Void {
        shared.register(object)
    }
    
    /// Detects memory leaks.
    public static func detect() -> Void {
        shared.detect()
    }
    
    
    // MARK: - Properties
    
    /// A string associated with the name of this detector.
    public let name: String = "Leak"
    
    /// A textual representation of the type of this detector.
    public let type: String = "Detector"
    
    /// The queue in which tracking performs.
    private let queue = DispatchQueue(label: "shared-leak-detector", qos: .background)
    
    /// Objects that are currently being tracked.
    private var trackedObjects = [RAWeakObject]()
    
    
    // MARK: - Methods
    
    /// Detects memory leaks.
    private func detect() -> Void {
        // 
    }
    
    /// Registers the given object by adding it to the tracked ones.
    private func register(_ object: RAObject) -> Void {
        queue.async {
            self.removeEmptyObjects()
            self.checkForUniqueness(object)
            self.beginTracking(object)
        }
    }
    
    /// Begins tracking the given object.
    private func beginTracking(_ object: RAObject) -> Void {
        let weakObject = RAWeakObject(safeReference: object)
        self.trackedObjects.append(weakObject)
    }
    
    /// Checks for the presence of a tracked object with the same name and type.
    private func checkForUniqueness(_ checkedObject: RAObject) -> Void {
        for trackedObject in trackedObjects {
            if trackedObject.name == checkedObject.name,
               trackedObject.type == checkedObject.type {
                log("Unexpectedly found objects with the same `\(checkedObject.name)` name and `\(checkedObject.type)` type",
                    level: .warning)
            }
        }
    }
    
    /// Removes tracked objects that reference `nil` objects.
    private func removeEmptyObjects() -> Void {
        trackedObjects = trackedObjects.filter { $0.reference.hasValue }
    }
    
    /// Logs a message by specifying a category as "Memory".
    private func log(_ message: String, level: RALogLevel, fileID: String = #fileID, function: String = #function, line: Int = #line) {
        RABlackBox.log(message, author: description, category: .memory, level: level, fileID: fileID, function: function, line: line)
    }
    
    
    // MARK: - Private Init
    
    /// Creates a leak detector.
    private init() {}
    
}
