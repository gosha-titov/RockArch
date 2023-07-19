// Implementation notes
// ====================
//
// When a module needs to load a child module into the module tree,
// it creates it by calling the `buildChildModule(byName:)` method.

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
/// The builder also has a lifecycle consisting of the `setup()` and `clean()` methods.
/// You can override these to perform additional initialization on your private properties and, accordingly, to clean them.
open class RABuilder: RAComponent, RAIntegratable {
    
    // MARK: - Properties
    
    /// A module into which this builder is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this builder.
    internal weak var _module: RAModule?
    
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
    /// - Returns: The created child module; otherwise, `nil`.
    internal final func buildChildModule(byName childName: String) -> RAModule? {
        guard let child = build(by: childName) else {
            log("Couldn't build a module by name `\(childName)`",
                category: .moduleManagement, level: .error)
            return nil
        }
        return child
    }
    
    
    // MARK: - Lifecycle
    
    /// Setups this builder before it starts working.
    ///
    /// This method is called when the module into which this builder integrated is assembled but not yet loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this builder after it stops working.
    ///
    /// This method is called when the module into which this builder integrated is about to be unloaded from the module tree and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    
    // MARK: - Init and Deinit
    
    /// Creates a builder instance.
    public init() {
        RALeakDetector.register(self)
    }
    
    deinit {
        RALeakDetector.release(self)
    }
    
}
