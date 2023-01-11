import UIKit

open class RAModule: RAComponent {
    
    /// The root module of the application.
    internal private(set) static var root: RAModule? = nil
    
    
    // MARK: - Public Properties
    
    /// A string associated with the name of this module.
    public let name: String
    
    /// A textual representation of the type of this module.
    public let type: String = "Module"
    
    /// The current state of this module.
    public private(set) var state: RAComponentState = .inactive
    
    /// A boolean value that indicates whether this modue is active.
    public final var isActive: Bool { state == .active }
    
    /// A boolean value that indicates whether this modue is inactive.
    public final var isInactive: Bool { state == .inactive }
    
    /// A boolean value that indicates whether this modue is suspended.
    public final var isSuspended: Bool { state == .suspended }
    
    /// A boolean value that indicates whether this module is loaded into the parent memory.
    public private(set) var isLoaded: Bool = false
    
    
    // MARK: Internal Properties
    
    /// A parent module that owns this module, or `nil`.
    internal weak var parent: RAModule?
    
    /// The internal interactor of this module.
    internal let interactor: RAAbstractInteractor
    
    /// The internal router of this module.
    internal let router: RARouter
    
    /// The internal view of this module, or `nil`.
    internal let view: RAAbstractView?
    
    /// The internal builder of this module, or `nil`.
    internal let builder: RABuilder?
    
    
    // MARK: Private Properties
    
    /// A dictionary that stores created and loaded child modules.
    private var children = [String: RAModule]()
    
    
    // MARK: - Child Management
    
    /// Adds a specific module to children by its name.
    private func attach(_ child: RAModule) -> Void {
        children[child.name] = child
        child.parent = self
    }
    
    /// Removes a specific module from children by its name.
    private func detach(_ child: RAModule) -> Void {
        children.removeValue(forKey: child.name)
        child.parent = nil
    }
    
    /// Builds a specific child module by its name if possible.
    private func build(by childName: String) -> RAModule? {
        guard let builder else {
            log(
                "Cannot build the `\(childName)` child module because this module doesn't have a builder.",
                category: RACategory.childManagement,
                level: .error
            )
            return nil
        }
        let childModule = builder.build(by: childName)
        return (childModule is RAEmpty) ? nil : childModule
    }
    
    
    // MARK: - Assembly and Disassembly
    
    /// Assembles this module by connecting its components to each other and to itself.
    private func assemble() -> Void {
        view?._interactor = interactor
        interactor._router = router
        interactor._view = view
        interactor._module = self
        router._module = self
        view?._module = self
    }
    
    /// Disassembles this module by disconnecting components from each other and from itself.
    private func disassemble() -> Void {
        view?._interactor = nil
        interactor._router = nil
        interactor._view = nil
        interactor._module = nil
        router._module = nil
        view?._module = nil
    }
    
    
    // MARK: - Lifecycle
    
    /// Called when a parent module loads this module into its memory.
    internal final func load() -> Void {
        defer { log("Loaded into memory", category: RACategory.moduleLifecycle) }
        assemble()
        isLoaded = true
    }
    
    /// Called when a parent module starts this module.
    internal final func start() -> Void {
        defer { log("Started working", category: RACategory.moduleLifecycle) }
        state = .active
    }
    
    /// Called when this module starts a child module.
    internal final func suspend() -> Void {
        defer { log("Suspended working", category: RACategory.moduleLifecycle) }
        state = .suspended
    }
    
    /// Called when a child module stops its work.
    internal final func resume() -> Void {
        defer { log("Resumed working", category: RACategory.moduleLifecycle) }
        state = .active
    }
    
    /// Called when this module should stop its work for some reason.
    internal final func stop() -> Void {
        defer { log("Stopped working", category: RACategory.moduleLifecycle) }
        state = .inactive
    }
    
    /// Called when a parent module unloads this module from its memory.
    internal final func unload() -> Void {
        defer { log("Unloaded from memory", category: RACategory.moduleLifecycle) }
        disassemble()
        isLoaded = false
    }
    
    
    // MARK: - Init and Deinit
    
    /// Creates a named module with the given components.
    ///
    /// - Parameter name: A string that will be associated with this module.
    /// The inner components (interactor, router, view, builder) of this module will also have this name.
    /// It will be displayed in logs, paths, links, etc.
    ///
    /// - Parameter interactor: The interactor that is responsible for all business logic of this module.
    /// It's also a built-in delegate of the module lifecycle and It can interact with other related interactors.
    /// Implement this by subclassing the `RAInteractor` class.
    ///
    /// - Parameter router: The router that is responsible for the hierarchy of modules.
    /// It can show and hide child modules, and it can complete this module.
    /// Implement this by subclassing the `RARouter` class.
    ///
    /// - Parameter view: The view that is responsible for configurating and updating UI, catching and handling user interactions.
    /// Implement this by subclassing the `RAView` class.
    /// If this is a logical module that doesn't have a view, then pass `nil` (default).
    ///
    /// - Parameter builder: The builder that is responsible for creating child modules by their associated names.
    /// Implement this by subclassing the `RABuilder` class.
    /// If this module don't have child modules, then pass `nil` (default).
    ///
    public init(name: String, interactor: RAAbstractInteractor, router: RARouter, view: RAAbstractView? = nil, builder: RABuilder? = nil) {
        defer { log("Created", category: RACategory.moduleLifecycle) }
        self.name = name
        self.interactor = interactor
        self.router = router
        self.view = view
        self.builder = builder
        RALeakDetector.register(self)
    }
    
    deinit {
        log("Deleted", category: RACategory.moduleLifecycle)
    }
    
}


/// A module that is marked as empty. That is, it cannot be added to the module tree.
final internal class RAEmptyModule: RAModule, RAEmpty {
    
    /// Creates an empty module.
    internal init() {
        super.init(name: "Empty", interactor: RAEmptyInteractor(), router: RAEmptyRouter())
    }
    
}
