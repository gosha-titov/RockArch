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
