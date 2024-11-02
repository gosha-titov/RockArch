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
public struct RADeepLink {
    
    /// Returns a new deep link where the given root module is the entry point of this link.
    /// - Parameter rootModuleName: The name associated with the root module.
    @inlinable public static func root(_ rootModuleName: String) -> RADeepLink {
        return RADeepLink().then(to: rootModuleName)
    }
    
    /// The array of elements that are arranged in the order in which they should be opened.
    public let elements: [Element]
    
    /// A string associated with the name of this deep link.
    ///
    /// You usually name links like: *OpenChat* or *ShowFriendProfile*.
    /// Names do not affect anything. They are used to understand more clearly what should happen.
    /// It's used for debugging or logging.
    public let name: String?
    
    
    // MARK: Methods
    
    /// Passes this deep link to the root module so that it opens the last module in the elements.
    /// - Parameter animated: Specify `true` to animate the opening transition, 
    /// or `false` if you do not want the transition to be animated. The default value is `true`.
    @MainActor public func open(animated: Bool = true) -> Void {
        RAModule.open(deeplink: self, animated: animated)
    }
    
    /// Returns a new deep link where the given module added to the top of this link.
    /// - Parameter moduleName: The name associated with a specific module.
    /// - Parameter context: The context to be provided to this module.
    @inlinable public func then(to moduleName: String, with context: RAContext? = nil) -> RADeepLink {
        let element = Element(name: moduleName, context: context)
        return then(to: element)
    }
    
    /// Returns a new deep link where the given element added to the top of this link.
    @inlinable public func then(to element: Element) -> RADeepLink {
        return RADeepLink(elements: elements.appending(element), name: name)
    }
    
    /// Returns a new deep link with the given name.
    @inlinable public func named(_ linkName: String) -> RADeepLink {
        return RADeepLink(elements: elements, name: linkName)
    }
    
    
    // MARK: Init
    
    /// Creates a deep link instance.
    @inlinable internal init(elements: [Element] = [], name: String? = nil) {
        self.elements = elements
        self.name = name
    }
    
}



// MARK: - Element

extension RADeepLink {
    
    /// An element of the link that associated with a certain module.
    public struct Element {
        
        /// The string associated with the name of a certain module.
        public let name: String
        
        /// A context to be provided to a certain module.
        public let context: RAContext?
        
        /// Creates a link element instance.
        /// - Parameter name: The name associated with the certain module.
        /// - Parameter context: The context to be provided to this module.
        @inlinable public init(name: String, context: RAContext?) {
            self.name = name
            self.context = context
        }
        
    }
    
}



// MARK: - CustomStringConvertible

extension RADeepLink: CustomStringConvertible {
    
    /// A textual representation of this deep link.
    ///
    /// For example, the link to the *Post* module may look like this:
    ///
    ///     print(deeplink)
    ///     // Prints "DeepLink(OpenPost): Main -> Feed -> Post"
    ///
    public var description: String {
        let maybeName = if let name { "(\(name))" } else { "" }
        return "DeepLink\(maybeName):" + elements.toString(separator: " –> ")
    }
    
}


extension RADeepLink.Element: CustomStringConvertible {
    
    /// A textual representation of this link element.
    ///
    /// This property returns the name of this element.
    public var description: String { name }
    
}
