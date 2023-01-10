public final class RALeakDetector {
    
    /// The singleton leak detector instance.
    internal static let shared = RALeakDetector()
    
    /// Registers a specific object by adding it to the tracked list.
    internal static func register(_ object: RAObject) -> Void {
        
    }
    
    
    // MARK: - Private Init
    
    /// Creates a leak detector.
    private init() {}
    
}
