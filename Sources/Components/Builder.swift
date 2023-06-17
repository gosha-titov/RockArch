/// A builder that is responsible for creating child modules by their associated names.
///
/// The builder is used when a module can have child modules. So, it uses a builder to create them.
///
/// You always define a new class that subclasses the `RABuilder` class and override the `build(by:)` method.
/// For example, you create a builder for the `Main` module that can have the `Feed` and `Chat` child modules:
///
///     final class MainBuilder: RABuilder {
///
///         override func build(by name: String) -> RAModule? {
///         switch name {
///         case "Feed": return FeedModule()
///         case "Chat": return ChatModule()
///         default: return nil
///         }
///
///     }
///
/// The builder also has a lifecycle that consists of the `setup()` and `clean()` methods.
/// You can override these to perform additional initialization on your private properties and, accordingly, to clean them.
open class RABuilder: RAComponent, RAIntegratable {
    
    // MARK: - Properties
    
    /// A module into which this builder is integrated.
    public weak var module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Builder" value.
    public let type: String = "Builder"
    
    
    // MARK: - Building Modules
    
    /// Builds a child module by its associated name.
    ///
    /// You should override this method in one of the following ways:
    ///
    /// **– Direct way (quick).** Use a switch statement to figure out which of the modules should be built and call the corresponding method:
    ///
    ///     override func build(by name: String) -> RAModule? {
    ///         switch name {
    ///         case "Messages": return buildMessagesModule()
    ///         case "Settings": return buildSettingsModule()
    ///         ...
    ///         default: return nil
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
    ///     override func build(by name: String) -> RAModule? {
    ///         switch name {
    ///         case "Messages": return MessagesModule()
    ///         case "Settings": return SettingsModule()
    ///         ...
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method.
    open func build(by name: String) -> RAModule? { return nil }
    
    /// Builds a child module by its associated name.
    /// - Note: The module should not call the `build(by:)` method directly, so it calls this internal `buildChildModule(byName:)` method.
    /// - Returns: The created child module; otherwise, a stub module.
    internal final func buildChildModule(byName childName: String) -> RAModule {
        if let childModule = build(by: childName) {
            return childModule
        } else {
            log("Couldn't build a module by name `\(childName)`",
                category: "ModuleManagement",
                level: .error)
            return RAStubModule()
        }
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this builder before it starts working.
    ///
    /// This method is called when the module into which this builder integrated is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this builder after it stops working.
    ///
    /// This method is called when the module into which this builder integrated is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Performs internal setup for this builder before it starts working.
    ///
    /// Only the module into which this builder integrated should call this method when it is loaded into memory and assembled.
    /// - Note: The module should not call the `setup()` method directly, so it calls this internal `_setup()` method.
    internal final func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Performs internal cleaning for this builder after it stops working.
    ///
    /// Only the module into which this builder integrated should call this method when it is about to be unloaded from memory and disassembled.
    /// - Note: The module should not call the `clean()` method directly, so it calls this internal `_clean()` method.
    internal final func _clean() -> Void {
        clean() // Should be called first
    }
    
    
    // MARK: - Init
    
    /// Creates a builder instance.
    public init() {}
    
}
