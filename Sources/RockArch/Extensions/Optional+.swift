internal extension Optional {
    
    /// A boolean value that indicates whether the optional object is `nil`.
    ///
    ///     var age: Int?
    ///     age.isNil // true
    ///
    var isNil: Bool { self == nil }
    
    /// A boolean value that indicates whether the optional object is not `nil`.
    ///
    ///     var name: String? = "gosha"
    ///     name.hasValue // true
    ///
    var hasValue: Bool { self != nil }
    
}
