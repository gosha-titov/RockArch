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
