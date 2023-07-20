public struct RADeepLink: RAObject {
    
    /// A string associated with the name of this deep link.
    public let name: String
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "DeepLink" value.
    public let type = "DeepLink"
    
    /// Creates a named deep link instance.
    private init(_ name: String) {
        self.name = name
    }
    
}
