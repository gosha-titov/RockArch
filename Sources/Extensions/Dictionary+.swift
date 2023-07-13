internal extension Dictionary.Keys {
    
    /// Returns an array consisting of keys.
    ///
    /// Unfortunately, you can't get the array of keys directly.
    /// Therefore, we have to use such "hacks":
    ///
    ///     let dict = ["a": 1, "b": 2]
    ///     let keys: [String] = dict.keys.asArray // ["a", "b"]
    ///
    var asArray: [Key] {
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
    var asArray: [Value] {
        return Array(self)
    }
    
}
