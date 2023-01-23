/// A storage that weakly stores specific modules.
internal final class RAWeakModuleStorage: RAWeakStorage<RAModule> {
    
    /// The singleton weak module storage instance.
    internal static let shared = RAWeakModuleStorage()
    
    /// Creates a weak module storage instance.
    private init() {
        super.init(name: "WeakModule")
    }
    
}


/// A storage that weakly stores specific interactors.
internal final class RAWeakInteractorStorage: RAWeakStorage<RAAbstractInteractor> {
    
    /// The singleton weak interactor storage instance.
    internal static let shared = RAWeakInteractorStorage()
    
    /// Creates a weak interactor storage instance.
    private init() {
        super.init(name: "WeakInteractor")
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
///         var dependency: Dependency? {
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
open class RAWeakStorage<Object>: RAAbstractStorage<Object, RAWeakObject> where Object: AnyObject {

    public final override func object(byKey key: String) -> Object? {
        return storedObjects[key]?.reference as? Object
    }
    
    public final override func register(_ object: Object, forKey key: String) -> Void {
        let weakObject: RAWeakObject
        if let object = object as? RAObject {
            weakObject = .init(directReference: object)
        } else {
            weakObject = .init(name: "Unnamed", type: "AnyObject", reference: object)
        }
        storedObjects[key] = weakObject
    }
    
    public override init(name: String = "Weak") {
        super.init(name: name)
    }

}


/// A storage that strongly stores specific objects.
///
/// The strong storage is mainly use when you need to extend some type with a stored object:
///
///     // Define a new class that subclasses the `RAStrongStorage` class:
///     final class DependencyStorage: RAStrongStorage<Dependency> {
///
///         static let shared = DependencyStorage()
///
///     }
///
///     // Then extend a type with this storage:
///     extension Object {
///
///         var dependency: Dependency? {
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
open class RAStrongStorage<Object>: RAAbstractStorage<Object, RAWrappedObject> where Object: AnyObject {
    
    public final override func object(byKey key: String) -> Object? {
        return storedObjects[key]?.value as? Object
    }
    
    public final override func register(_ object: Object, forKey key: String) -> Void {
        let wrappedObject: RAWrappedObject
        if let object = object as? RAObject {
            wrappedObject = .init(directReference: object)
        } else {
            wrappedObject = .init(name: "Unnamed", type: "AnyObject", objectToWrap: object)
        }
        storedObjects[key] = wrappedObject
    }
    
    public override init(name: String = "Strong") {
        super.init(name: name)
    }
    
}


/// An abstract storage that has a basic behavior.
open class RAAbstractStorage<ObjectToStore, ObjectThatStores>: RAStorage where ObjectToStore: AnyObject, ObjectThatStores: AnyObject {
    
    // MARK: Properties
    
    /// A string associated with the name of this storage.
    public let name: String
    
    /// The string that has the "Storage" value.
    public let type: String = "Storage"
    
    /// The array that consists of stored objects.
    fileprivate var storedObjects = [String: ObjectThatStores]()
    
    
    // MARK: Methods
    
    /// Returns an object by the given key.
    public func object(byKey key: String) -> ObjectToStore? {
        // Must be overriden
        return nil
    }
    
    /// Removes an object for the given key.
    public final func removeObject(forKey key: String) -> Void {
        storedObjects.removeValue(forKey: key)
    }
    
    /// Registers a specific object for the given key.
    public func register(_ object: ObjectToStore, forKey key: String) -> Void {
        // Must be overriden
    }
    
    
    // MARK: Init
    
    /// Creates a named storage instance.
    fileprivate init(name: String = "Abstract") {
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
