internal extension Dictionary {
    
    /// Returns a boolean value that indicates whether the given key exists in this dictionary.
    ///
    ///     let dict = [0: "a", 1: "b", 2: "c"]
    ///     dict.hasKey(2) // true
    ///     dict.hasKey(3) // false
    ///
    @inlinable func hasKey(_ key: Key) -> Bool { self[key] != nil }
    
}


internal extension Dictionary.Keys {
    
    /// Returns an array consisting of keys.
    ///
    /// Unfortunately, you can't get the array of keys directly.
    /// Therefore, we have to use such "hacks":
    ///
    ///     let dict = ["a": 1, "b": 2]
    ///     let keys: [String] = dict.keys.asArray // ["a", "b"]
    ///
    @inlinable var asArray: [Key] {
        return Array(self)
    }
    
}


internal extension Dictionary.Values {
    
    /// Returns an array consisting of values.
    ///
    /// Unfortunately, you can't get the array of values directly.
    /// Therefore, we have to use such "hacks":
    ///
    ///     let dict = ["a": 1, "b": 2]
    ///     let values: [Int] = dict.values.asArray // [1, 2]
    ///
    @inlinable var asArray: [Value] {
        return Array(self)
    }
    
}


internal extension Dictionary where Key == String, Value == RAModule {
    
    /// Returns a boolean value that indicates whether the given module-value exists in this dictionary.
    @inlinable func contains(value module: RAModule) -> Bool {
        guard let child = self[module.name] else { return false }
        return child === module
    }
    
}
