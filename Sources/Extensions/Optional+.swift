internal extension Optional {
    
    /// A boolean value that indicates whether the optional object is `nil`.
    ///
    ///     var age: Int?
    ///     age.isNil // true
    ///
    @inlinable var isNil: Bool { self == nil }
    
    /// A boolean value that indicates whether the optional object is not `nil`.
    ///
    ///     var name: String? = "gosha"
    ///     name.hasValue // true
    ///
    @inlinable var hasValue: Bool { self != nil }
    
}


internal extension Optional where Wrapped: Collection {
    
    /// A boolean value that indicates whether the optional object is `nil` or empty.
    ///
    ///     var str: String? = nil
    ///     str.isNilOrEmpty // true
    ///
    ///     var array: [Int]? = []
    ///     array.isNilOrEmpty // true
    ///
    ///     var dict: [Int: String]? = [12: "34"]
    ///     dict.isNilOrEmpty // false
    ///
    @inlinable var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}
