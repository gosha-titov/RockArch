open class RAModule: RAComponent {
    
    // MARK: General Info
    
    /// A string associated with the name of this module.
    public let name: String
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Module" value.
    public let type: String = "Module"
    
    /// The current state of this module.
    public private(set) var state: RAComponentState = .inactive
    
    /// A boolean value that indicates whether this module is loaded into the parent memory.
    public private(set) var isLoaded: Bool = false
    
    
    // MARK: Relatives
    
    /// The root module of the application.
    internal private(set) static var root: RAModule? = nil
    
    /// A parent module that owns this module, or `nil`.
    internal weak var parent: RAModule?
    
    /// The dictionary that stores created (and loaded) child modules by their names.
    private var children = [String: RAModule]()
    
    
    // MARK: Inner Components
    
    /// The internal interactor of this module.
    internal let interactor: RAInteractor
    
    /// The internal router of this module.
    internal let router: RARouter
    
    /// The internal view of this module, or `nil`.
    internal let view: (any RAView)?
    
    /// The internal builder of this module, or `nil`.
    internal let builder: RABuilder?
    
    
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
    
    
    // MARK: - Lifecycle
    
    /// Setups this module before it starts working.
    ///
    /// This method is called when this module is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this module after it stops working.
    ///
    /// This method is called when this module is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Performs internal setup for this module before it starts working.
    private func _setup() -> Void {
        setup() // Should be called first
    }
    
    /// Performs internal clean for this module after it stops working.
    private func _clean() -> Void {
        clean() // Should be called last
    }
    
    /// Called when a parent module loads this module into its memory.
    internal final func load() -> Void {
        defer { log("Loaded into memory", category: "ModuleLifecycle") }
        isLoaded = true
    }
    
    /// Called when a parent module starts this module.
    internal final func start() -> Void {
        defer { log("Started working", category: "ModuleLifecycle") }
        state = .active
    }
    
    /// Called when this module starts a child module.
    internal final func suspend() -> Void {
        defer { log("Suspended working", category: "ModuleLifecycle") }
        state = .suspended
    }
    
    /// Called when a child module stops its work.
    internal final func resume() -> Void {
        defer { log("Resumed working", category: "ModuleLifecycle") }
        state = .active
    }
    
    /// Called when this module should stop its work for some reason.
    internal final func stop() -> Void {
        defer { log("Stopped working", category: "ModuleLifecycle") }
        state = .inactive
    }
    
    /// Called when a parent module unloads this module from its memory.
    internal final func unload() -> Void {
        defer { log("Unloaded from memory", category: "ModuleLifecycle") }
        isLoaded = false
    }
    
    
    // MARK: - Init and Deinit
    
    /// Creates a named module instance with the given components.
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
    /// Implement this by creating a new class that conforms to the `RAView` protocol.
    /// If this is a logical module that doesn't have a view, then pass `nil` (default).
    ///
    /// - Parameter builder: The builder that is responsible for creating child modules by their associated names.
    /// Implement this by subclassing the `RABuilder` class.
    /// If this module don't have child modules, then pass `nil` (default).
    ///
    public init(name: String, interactor: RAInteractor, router: RARouter, view: (any RAView)? = nil, builder: RABuilder? = nil) {
        defer { log("Created", category: "ModuleLifecycle") }
        self.name = name
        self.interactor = interactor
        self.router = router
        self.view = view
        self.builder = builder
        RALeakDetector.register(self)
    }
    
    deinit {
        log("Deleted", category: "ModuleLifecycle")
    }
    
}



internal final class RAStubModule: RAModule {
    
    internal init() {
        super.init(name: "Stub", interactor: RAStubInteractor(), router: RAStubRouter())
    }
    
}
