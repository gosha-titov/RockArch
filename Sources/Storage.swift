/// A storage that weakly stores specific interactors.
internal final class RAWeakInteractorStorage: RAWeakStorage<RAInteractor> {
    
    /// The singleton weak interactor storage instance.
    internal static let shared = RAWeakInteractorStorage()
    
    /// Creates a weak interactor storage instance.
    private init() {
        super.init(name: "WeakInteractor")
    }
    
}



/// A storage that weakly stores specific objects.
///
/// Weak storages are used when you need to extend an existent type with a stored property that weakly references to an object.
///
///     // Define a new class that subclasses the `RAWeakStorage` class:
///     final class DependencyStorage: RAWeakStorage<Dependency> {
///
///         static let shared = DependencyStorage()
///
///         private init() {
///             super.init(name: "WeakDependency")
///         }
///
///     }
///
///
///     // Then extend an existent type using this storage:
///     extension Object {
///
///         var dependency: Dependency? {
///             get {
///                 let storage = DependencyStorage.shared
///                 return storage[debugDescription]
///             }
///             set {
///                 let storage = DependencyStorage.shared
///                 storage[debugDescription] = newValue
///             }
///         }
///
///     }
///
/// Now this above property has the same behavior as the weak reference:
///
///     final class Object {
///
///         weak var dependency: Dependency?
///
///     }
///
open class RAWeakStorage<StoredObject>: RAAbstractStorage<StoredObject> where StoredObject: AnyObject {

    /// The array that consists of elements that weakly reference some objects.
    private var weakObjects = [String: RAWeakObject]()
    
    public final override func value(forKey key: String) -> StoredObject? {
        return weakObjects[key]?.reference as? StoredObject
    }
    
    public final override func removeValue(forKey key: String) -> StoredObject? {
        let removedObject = weakObjects.removeValue(forKey: key)
        return removedObject?.reference as? StoredObject
    }
    
    public final override func updateValue(_ object: StoredObject, forKey key: String) -> Void {
        let weakObject: RAWeakObject
        if let object = object as? RAAnyObject {
            weakObject = .init(reflecting: object)
        } else {
            weakObject = .init(referencing: object)
        }
        weakObjects[key] = weakObject
    }
    
    /// Creates a named storage instance.
    /// - Parameter name: A name of this storage. You usually specify the string concatenating the name of a stored object
    /// with the "Weak" prefix, as in the following example: "WeakDependency".
    public override init(name: String = "Weak") {
        super.init(name: name)
    }

}



/// A storage that strongly stores specific objects.
///
/// Strong storages are used when you need to extend an existent type with a stored property that strongly references to an object.
///
///     // Define a new class that subclasses the `RAStrongStorage` class:
///     final class DependencyStorage: RAStrongStorage<Dependency> {
///
///         static let shared = DependencyStorage()
///
///         private init() {
///             super.init(name: "StrongDependency")
///         }
///
///     }
///
///
///     // Then extend an existent type using this storage:
///     extension Object {
///
///         var dependency: Dependency? {
///             get {
///                 let storage = DependencyStorage.shared
///                 return storage[debugDescription]
///             }
///             set {
///                 let storage = DependencyStorage.shared
///                 storage[debugDescription] = newValue
///             }
///         }
///
///     }
///
/// Now this above property has the same behavior as the strong reference:
///
///     final class Object {
///
///         var dependency: Dependency?
///
///     }
///
open class RAStrongStorage<StoredObject>: RAAbstractStorage<StoredObject> where StoredObject: AnyObject {
    
    /// The array that consists of elements that strongly reference some objects.
    private var strongObjects = [String: RAStrongObject]()
    
    public final override func value(forKey key: String) -> StoredObject? {
        return strongObjects[key]?.reference as? StoredObject
    }
    
    public final override func removeValue(forKey key: String) -> StoredObject? {
        let removedObject = strongObjects[key]?.reference
        return removedObject as? StoredObject
    }

    public final override func updateValue(_ object: StoredObject, forKey key: String) -> Void {
        let strongObject: RAStrongObject
        if let object = object as? RAAnyObject {
            strongObject = .init(reflecting: object)
        } else {
            strongObject = .init(referencing: object)
        }
        strongObjects[key] = strongObject
    }
    
    /// Creates a named storage instance.
    /// - Parameter name: A name of this storage. You usually specify the string concatenating the name of a stored object
    /// with the "Strong" prefix, as in the following example: "StrongDependency".
    public override init(name: String = "Strong") {
        super.init(name: name)
    }

}



/// An abstract storage that has a basic behavior for other ones.
open class RAAbstractStorage<Stored>: RAStorage {
    
    // MARK: Properties
    
    /// A string associated with the name of this storage.
    public let name: String
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Storage" value.
    public let type = "Storage"
    
    
    // MARK: Methods
    
    /// Returns a value for the given key.
    ///
    /// If the given key is found in the storage, this method returns the key’s associated value.
    ///
    ///     if let dependency = storage.value(forKey: "Object") {
    ///         print("The name of the dependency is '\(dependency.name)'.")
    ///     }
    ///
    /// Instead of calling this method, use the following subscript:
    ///
    ///     if let dependency = storage["Object"] {
    ///         print("The name of the dependency is '\(dependency.name)'.")
    ///     }
    ///
    public func value(forKey key: String) -> Stored? {
        // Must be overriden
        return nil
    }
    
    /// Removes a value for the given key.
    ///
    /// If the key is found in the storage, this method returns the key’s associated value.
    ///
    ///     if let dependency = storage.removeValue(forKey: "Object") {
    ///         print("The name of the dependency is '\(dependency.name)'.")
    ///     }
    ///
    /// if you don't need to use a removed value, then you can use the following subscript:
    ///
    ///     storage["Object"] = nil
    ///
    @discardableResult
    public func removeValue(forKey key: String) -> Stored? {
        // Must be overriden
        return nil
    }
    
    /// Updates a value for the given key, or adds a new key-value pair if the key does not exist.
    ///
    ///     storage.updateValue(object, forKey: "Object")
    ///
    /// Instead of calling this method, use the following subscript:
    ///
    ///     storage["Object"] = object
    ///
    public func updateValue(_ value: Stored, forKey key: String) -> Void {
        // Must be overriden
    }
    
    
    // MARK: Subscript
    
    /// Accesses the value for the specific key.
    ///
    /// The following examples show how you can interact with the storage using this subscript:
    ///
    ///     // Get a value for the specific key
    ///     let value = storage[key]
    ///
    ///     // Set or update a value for the specific key
    ///     storage[key] = newValue
    ///
    ///     // Remove a value for the specific key
    ///     storage[key] = nil
    ///
    public final subscript(key: String) -> Stored? {
        get {
            let object = value(forKey: key)
            return object
        }
        set {
            if let newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    
    // MARK: Init
    
    /// Creates a named storage instance.
    fileprivate init(name: String) {
        self.name = name
    }
    
}



/// A type that can storage specific values.
///
/// This protocol is used for storages that allow you to extend an existent type with a stored property.
public protocol RAStorage: RAAnyObject {
    
    /// A type to store.
    associatedtype Stored
    
    /// Returns a value for the given key.
    func value(forKey key: String) -> Stored?
    
    /// Removes a value for the given key.
    func removeValue(forKey key: String) -> Stored?
    
    /// Updates a value for the given key, or adds a new key-value pair if the key does not exist.
    func updateValue(_ value: Stored, forKey key: String) -> Void
    
    /// Accesses the value for the specific key.
    subscript(key: String) -> Stored? { get set }
    
}
