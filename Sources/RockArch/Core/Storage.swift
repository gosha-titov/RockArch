internal final class RAModuleStorage: RAStorage<RAModule> {
    
    /// The singleton module storage instance.
    internal static let shared = RAModuleStorage()
    
    /// Creates a module storage instance.
    private init() {
        super.init(name: "Module")
    }
    
}

internal final class RAInteractorStorage: RAStorage<RAAbstractInteractor> {
    
    /// The singleton interactor storage instance.
    internal static let shared = RAInteractorStorage()
    
    /// Creates an interactor storage instance.
    private init() {
        super.init(name: "Interactor")
    }
    
}


internal class RAStorage<Object>: RAObject where Object: RAObject {
    
    // MARK: - Properties
    
    /// A string associated with the name of this storage.
    internal let name: String
    
    /// The string that has the "Storage" value.
    internal let type: String = "Storage"
    
    /// The array that consists of stored objects.
    private var storedObjects = [String: RAWeakObject]()
    
    
    // MARK: - Methods
    
    /// Returns an object by the given key.
    internal final func object(byKey key: String) -> Object? {
        return storedObjects[key]?.reference as? Object
    }
    
    /// Removes an object for the given key.
    internal final func removeObject(forKey key: String) -> Void {
        storedObjects.removeValue(forKey: key)
    }
    
    /// Registers a specific object for the given key.
    internal final func register(_ object: Object, forKey key: String) -> Void {
        let weakObject = RAWeakObject(safeReference: object)
        storedObjects[key] = weakObject
    }
    
    
    // MARK: - Init
    
    /// Creates a named storage instance.
    internal init(name: String = "Default") {
        self.name = name
    }
    
}
