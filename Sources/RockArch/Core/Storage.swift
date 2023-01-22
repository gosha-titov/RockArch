internal final class RAModuleStorage: RAWeakStorage<RAModule> {
    
    /// The singleton module storage instance.
    internal static let shared = RAModuleStorage()
    
    /// Creates a module storage instance.
    private init() {
        super.init(name: "Module")
    }
    
}

internal final class RAInteractorStorage: RAWeakStorage<RAAbstractInteractor> {
    
    /// The singleton interactor storage instance.
    internal static let shared = RAInteractorStorage()
    
    /// Creates an interactor storage instance.
    private init() {
        super.init(name: "Interactor")
    }
    
}


/// A storage that weakly stores specific objects.
///
/// The weak storage is mainly use when you need to extend some type with a stored object:
///
///     // Define a new class that subclasses the `RAWeakStorage` class:
///     final class DependencyStorage: RAWeakStorage<Dependency> {
///
///         static let shared = DependencyStorage()
///
///     }
///
///     // Then extend a type with this storage:
///     extension Object {
///
///         var dependency: Dependency {
///             get {
///                 let storage = DependencyStorage.shared
///                 return storage.object(byKey: debugDescription)
///             }
///             set {
///                 let storage = DependencyStorage.shared
///                 if let dependency = newValue {
///                     storage.register(dependency, forKey: debugDescription)
///                 } else {
///                     storage.removeObject(forKey: debugDescription)
///                 }
///             }
///         }
///
///     }
///
open class RAWeakStorage<Object>: RAStorage where Object: AnyObject {
    
    // MARK: - Properties
    
    /// A string associated with the name of this storage.
    public let name: String
    
    /// The string that has the "Storage" value.
    public let type: String = "Storage"
    
    /// The array that consists of stored objects.
    private var storedObjects = [String: RAWeakObject]()
    
    
    // MARK: - Methods
    
    /// Returns an object by the given key.
    public final func object(byKey key: String) -> Object? {
        return storedObjects[key]?.reference as? Object
    }
    
    /// Removes an object for the given key.
    public final func removeObject(forKey key: String) -> Void {
        storedObjects.removeValue(forKey: key)
    }
    
    /// Registers a specific object for the given key.
    public final func register(_ object: Object, forKey key: String) -> Void {
        let weakObject: RAWeakObject
        if let object = object as? RAObject {
            weakObject = .init(directReference: object)
        } else {
            weakObject = .init(name: "Unnamed", type: "AnyObject", reference: object)
        }
        storedObjects[key] = weakObject
    }
    
    
    // MARK: - Init
    
    /// Creates a named storage instance.
    public init(name: String = "Weak") {
        self.name = name
    }
    
}


/// A type that can storage specific objects.
public protocol RAStorage: RAObject {
    
    /// A type to store.
    associatedtype Object: AnyObject
    
    /// Returns an object by the given key.
    func object(byKey key: String) -> Object?
    
    /// Removes an object for the given key.
    func removeObject(forKey key: String) -> Void
    
    /// Registers a specific object for the given key.
    func register(_ object: Object, forKey key: String) -> Void
    
}
