/// A builder that can build child modules by their associated names.
///
/// The builder is used when a module can have child modules. So, it uses a builder to build them.
///
/// You always create a new class that subclasses the `RABuilder` class and override the `build(by:)` method.
/// For example, you create a builder for the `Main` module that can have the `Feed` and `Chat` child modules:
///
///     final class MainBuilder: RABuilder {
///
///         override func build(by name: String) -> RAModule {
///         switch name {
///         case "Feed": return FeedModule()
///         case "Chat": return ChatModule()
///         default: return super.build(by: name)
///         }
///
///     }
///
/// The builder also has a lifecycle that consists of the `setup()` and `clean()` methods.
/// You can override them if needed.
///
open class RABuilder: RAComponentIntegratedIntoModule {
    
    // MARK: - Properties
    
    /// A module to that this builder belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Builder" value.
    public let type: String = "Builder"
    
    
    // MARK: - Children Building
    
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
        log("Couldn't build a module by name `\(name)`",
            category: .moduleManagement,
            level: .error)
        return RAEmptyModule()
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this builder.
    ///
    /// This method is called when the module to which this builder belongs is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this builder.
    ///
    /// This method is called when the module to which this builder belongs is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    /// Called when the module is loaded into memory and assembled.
    internal final func _setup() -> Void {
        RALeakDetector.register(self)
        setup()
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal final func _clean() -> Void {
        clean()
    }
    
    
    // MARK: - Public Init
    
    /// Creates a builder.
    public init() {}
    
}
