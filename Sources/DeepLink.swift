/// A deep link that can open a specific module anywhere in the entire module tree along a given path.
///
/// The builder design pattern is used to create a deep link.
/// For example, the link to the *Post* module may look like this:
///
///     let link = RADeepLink
///         .root(MainModule.name)
///         .then(to: FeedModule.name)
///         .then(to: PostModule.name, with: postID)
///         .named("OpenPost")
///
///     link.open()
///
/// - Note: You can start creating a deep link only by calling the `root(_:)` static method first.
public struct RADeepLink: RAObject {
    
    /// Returns a deep link where the given root module is the entry point of this link.
    /// - Parameter rootModuleName: The name associated with the root module.
    public static func root(_ rootModuleName: String) -> RADeepLink {
        return RADeepLink().then(to: rootModuleName)
    }
    
    
    /// The string associated with the name of this deep link.
    ///
    /// You usually name links like: *OpenChat* or *ShowFriendProfile*.
    /// Names do not affect anything. They are used to understand more clearly what should happen.
    ///
    /// The default value is "Unnamed".
    public var name = "Unnamed"
    
    /// The textual representation of the type of this object.
    ///
    /// This property has the "DeepLink" value.
    public let type = "DeepLink"
    
    /// A textual representation of this deep link.
    ///
    /// For example, the link to the *Post* module may look like this:
    ///
    ///     print(deeplink)
    ///     // Prints "Main -> Feed -> Post"
    ///
    public var description: String {
        return elements.toString(separator: " –> ")
    }
    
    /// The list of elements that are arranged in the order in which they are opened.
    public private(set) var elements = [Element]()
    
    
    // MARK: Methods
    
    /// Returns a new deep link where the given module added to the top of this link.
    /// - Parameter moduleName: The name associated with a specific module.
    /// - Parameter context: The context to be provided to this module.
    public func then(to moduleName: String, with context: RAContext? = nil) -> RADeepLink {
        let element = Element(name: name, context: context)
        return then(to: element)
    }
    
    /// Returns a new deep link where the element to the top of this link.
    public func then(to element: Element) -> RADeepLink {
        var next = self
        next.elements.append(element)
        return next
    }
    
    /// Returns a new deep link with the given name.
    public func named(_ linkName: String) -> RADeepLink {
        var new = self
        new.name = linkName
        return new
    }
    
    
    // MARK: Init
    
    /// Creates a deep link instance.
    private init() {}
    
}



extension RADeepLink {
    
    /// An element of the link that associated with a specific module.
    public struct Element: CustomStringConvertible {
        
        /// The string associated with the name of a specific module.
        public let name: String
        
        /// A context to be provided to a specific module.
        public let context: RAContext?
        
        /// A textual representation of this link element.
        ///
        /// This property returns the name of this element.
        public var description: String { name }
        
        /// Creates a link element instance.
        /// - Parameter name: The name associated with the specific module.
        /// - Parameter context: The context to be provided to this module.
        public init(name: String, context: RAContext?) {
            self.name = name
            self.context = context
        }
        
    }
    
}
