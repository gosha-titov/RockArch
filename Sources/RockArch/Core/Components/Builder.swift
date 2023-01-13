/// A builder that can build child modules by their associated names.
open class RABuilder: RAComponent, RAModuleBelongable {
    
    // MARK: - Properties
    
    /// A name of the module to that this builder belongs.
    public final var name: String {
        return _module?.name ?? "Unnamed"
    }
    
    /// A textual representation of the type of this builder.
    public let type: String = "Builder"
    
    /// The current state of the module to that this builder belongs.
    public final var state: RAComponentState {
        return _module?.state ?? .inactive
    }
    
    /// An internal module to that this builder belongs.
    internal weak var _module: RAModule?
    
    
    // MARK: - Methods
    
    /// Builds a specific module by its name.
    ///
    /// You should override this method in one of the following ways:
    ///
    /// **– Direct way (quick).** Use a switch statement to figure out which of the modules should be built and call the corresponding method:
    ///
    ///     override func build(by name: String) -> RAModule {
    ///         switch name {
    ///         case "Messages": return buildMessagesModule()
    ///         case "Settings": return buildSettingsModule()
    ///         ...
    ///         default: return super.build(by: name)
    ///         }
    ///     }
    ///
    /// Then define these methods in which you create all their components as in the example:
    ///
    ///     final func buildMessagesModule() -> RAModule {
    ///         return RAModule(
    ///             name: "Messages",
    ///             interactor: MessagesInteractor(),
    ///             router:     MessagesRouter(),
    ///             view:       MessagesView(),    // optional
    ///             builder:    MessagesBuilder(), // optional
    ///         )
    ///     }
    ///
    /// **– Hidden way (preferred).** Define new classes that subclass the `RAModule` class
    /// and create all components inside their initializers as in the example:
    ///
    ///     final class MessagesModule: RAModule {
    ///
    ///         init() {
    ///             super.init(
    ///                 name: "Messages",
    ///                 interactor: MessagesInteractor(),
    ///                 router:     MessagesRouter(),
    ///                 view:       MessagesView(),    // optional
    ///                 builder:    MessagesBuilder(), // optional
    ///             )
    ///         }
    ///
    ///     }
    ///
    /// Then you use a switch statement to figure out which of the modules should be built and return the corresponding instance:
    ///
    ///     override func build(by name: String) -> RAModule {
    ///         switch name {
    ///         case "Messages": return MessagesModule()
    ///         case "Settings": return SettingsModule()
    ///         ...
    ///         default: return super.build(by: name)
    ///         }
    ///     }
    ///
    /// You should return a result of calling the `super` method when you cannot build a module.
    open func build(by name: String) -> RAModule {
        log("Cannot build a module by name `\(name)`",
            category: .moduleManagement,
            level: .error)
        return RAEmptyModule()
    }
    
    
    // MARK: - Public Init
    
    /// Creates a builder.
    public init() {
        RALeakDetector.register(self)
    }
    
}
