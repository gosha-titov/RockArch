/// The leak detector that monitors the deallocation of certain objects to avoid memory leaks.
public final class RALeakDetector: RAAnyObject {
    
    /// A string associated with the name of this object.
    ///
    /// This property has the "Leak" value.
    public let name = "Leak"
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Detector" value.
    public let type = "Detector"
    
    /// Creates a leak detector instance.
    private init() {}
    
}
