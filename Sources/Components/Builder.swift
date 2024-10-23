// Implementation notes
// ====================
//
// When a module needs to load a child module into the module tree,
// it creates this by calling the `buildChildModule(byName:with:)` method.

/// A builder that is responsible for creating child modules by their associated names and providing the necessary dependencies.
///
/// The builder is used when a module has child modules. So, it uses a builder to create them.
///
/// You always define a new class that subclasses the `RABuilder` class and override the `build(by:with:)` method.
/// For example, you create a builder for the *Main* module that can have the *Messages*, *Settings* and *Alert* child modules:
///
///     final class MainBuilder: RABuilder {
///
///         override func build(by name: String, with dependency: RADependency?) -> RAModule? {
///             switch name {
///             case MessagesModule.name:
///                 if let service = dependency as? MessagesServiceInterface {
///                     return MessagesModule(service: service)
///                 }
///             case SettingsModule.name:
///                 if let storage = dependency as? SettingsStorageInterface {
///                     return SettingsModule(storage: storage)
///                 }
///             case AlertModule.name:
///                 return AlertModule()
///             default:
///                 return nil
///             }
///         }
///
///     }
///
/// The builder has a lifecycle consisting of the `setup()` and `clean()` methods,
/// which are called when the module is attached to or detached from the module tree.
/// You can override these to perform additional initialization on your properties and, accordingly, to clean them.
///
/// - Note: Each component can log messages by calling the `log(_:category:level:)` method.
/// These messages are handled by the current black box with its loggers.
@MainActor
open class RABuilder: RAComponent, RAIntegratable {
    
    /// A module into which this builder is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this builder.
    internal weak var _module: RAModule?
    
    /// The textual representation of the type of this object.
    ///
    /// This property has the "Builder" value.
    public let type: String = "Builder"
    
    
    // MARK: Building Methods
    
    /// Builds a child module by its associated name and provides a dependency if needed.
    ///
    /// You should override this method the following way:
    ///
    /// Firstly, define a new class that subclasses the `RAModule` class
    /// and create all components inside their initializers as in the example:
    ///
    ///     final class AlertModule: RAModule {
    ///
    ///         static let name = "Alert"
    ///
    ///         init() {
    ///             super.init(
    ///                 name:       AlertModule.name,
    ///                 interactor: AlertInteractor(),
    ///                 router:     AlertRouter(),
    ///                 view:       AlertView()
    ///             )
    ///         }
    ///
    ///     }
    ///
    /// The module may also have a dependency:
    ///
    ///     final class SettingsModule: RAModule {
    ///
    ///         static let name = "Settings"
    ///
    ///         init(storage: SettingsStorageInterface) {
    ///             super.init(
    ///                 name:       SettingsModule.name,
    ///                 interactor: SettingsInteractor(storage: storage),
    ///                 router:     SettingsRouter(),
    ///                 view:       SettingsView(),
    ///                 builder:    SettingsBuilder()
    ///             )
    ///         }
    ///
    ///     }
    ///
    /// Secondly, use a switch statement to figure out which of the modules should be built and return the corresponding instance:
    ///
    ///     override func build(by name: String, with dependency: RADependency?) -> RAModule? {
    ///         switch name {
    ///         case MessagesModule.name: 
    ///             if let service = dependency as? MessagesServiceInterface {
    ///                 return MessagesModule(service: service)
    ///             }
    ///         case SettingsModule.name:
    ///             if let storage = dependency as? SettingsStorageInterface {
    ///                 return SettingsModule(storage: storage)
    ///             }
    ///         case AlertModule.name:
    ///             return AlertModule()
    ///         ...
    ///         default: 
    ///             return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method, because the default implementation does nothing.
    /// - Returns: The built child module; otherwise, `nil`.
    open func build(by name: String, with dependency: RADependency?) -> RAModule? { return nil }
    
    /// Builds a child module by its associated name and provides a dependency if needed.
    /// - Returns: The built child module; otherwise, `nil`.
    internal final func buildChildModule(byName childName: String, with dependency: RADependency?) -> RAModule? {
        guard let child = build(by: childName, with: dependency) else {
            log("Couldn't build a module by name `\(childName)`",
                category: .moduleManagement, level: .error)
            return nil
        }
        return child
    }
    
    
    // MARK: Lifecycle Methods
    
    /// Setups this builder before it starts working.
    ///
    /// This method is called when the module into which this builder integrated is assembled and loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func setup() -> Void {}
    
    /// Cleans this builder after it stops working.
    ///
    /// This method is called when the module into which this builder integrated is about to be unloaded from the module tree and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func clean() -> Void {}
    
    
    // MARK: Init and Deinit
    
    /// Creates a builder instance.
    public init() {
        RALeakDetector.register(self)
    }
    
    deinit {
//        RALeakDetector.release(self)
    }
    
}
