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
    
    /// The child modules embedded in this module.
    private var embeddedModules: [String: RAModule] {
        return children.filter { namesOfEmbeddedModules.contains($0.key) }
    }
    
    /// The names of the child modules embedded in this module.
    public private(set) var namesOfEmbeddedModules = [String]()
    
    /// The names of the child modules that should be embedded during the loading of this module.
    private var namesOfChildModulesThatShouldBeEmbedded = [String]()
    
    
    // MARK: Inner Components
    
    /// The internal interactor of this module.
    internal let interactor: RAInteractor
    
    /// The internal router of this module.
    internal let router: RARouter
    
    /// The internal view of this module, or `nil`.
    internal let view: (any RAView)?
    
    /// The internal builder of this module, or `nil`.
    internal let builder: RABuilder?
    
    
    // MARK: Delegate and Data Source
    
    /// The object that acts as the lifecycle delegate of this module.
    private let lifecycleDelegate: RAModuleLifecycleDelegate
    
    /// The object that provides the data for child modules of this module.
    private let dataSource: RAModuleDataSource
    
    
    
    // MARK: - Embedding Modules
    
    /// Embeds a specific module into this module by its associated name.
    ///
    /// It's used for a composite module. For example, for a tab bar module:
    ///
    ///     override func setup() -> Void {
    ///         embedChildModule(byName: "Feed")
    ///         embedChildModule(byName: "Messages")
    ///         embedChildModule(byName: "Settings")
    ///     }
    ///
    /// - Note: You can embed a child module only before this module is loaded into memory.
    public final func embedChildModule(byName childName: String) -> Void {
        guard isLoaded == false else {
            log("Couldn't embed the `\(childName)` child module because this module was loaded",
                category: "ModuleManagement",
                level: .error)
            return
        }
        guard namesOfChildModulesThatShouldBeEmbedded.contains(childName) == false else {
            log("Couldn't embed the `\(childName)` child module twice",
                category: "ModuleManagement",
                level: .warning)
            return
        }
        namesOfChildModulesThatShouldBeEmbedded.append(childName)
    }
    
    /// Embeds a specific child modules into this module by loading it into memory.
    private func embedChildModulesIfNeeded() -> Void {
        namesOfChildModulesThatShouldBeEmbedded.removeDuplicates()
        for childName in namesOfChildModulesThatShouldBeEmbedded {
            let childIsLoaded = loadChildModule(byName: childName)
            if childIsLoaded {
                namesOfEmbeddedModules.append(childName)
                log("Embedded the `\(childName)` child module successfully",
                    category: "ModuleManagement")
            } else {
                log("Couldn't embed the `\(childName)` child module because it couldn't be loaded",
                    category: "ModuleManagement",
                    level: .error)
            }
        }
    }
    
    
    // MARK: - Building and Loading Modules
    
    /// Preloads a specific child module into memory.
    /// - Returns: `True` if the child module has been loaded into memory; otherwise, `false`.
    internal final func loadChildModule(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't load the `\(childName)` child module because this module wasn't loaded into memory",
                category: "ModuleManagement",
                level: .error)
            return false
        }
        guard children[childName].isNil else {
            log("Couldn't load the `\(childName)` child module because it was already loaded into memory",
                category: "ModuleManagement",
                level: .warning)
            return false
        }
        guard let builtChild = buildChildModule(byName: childName) else {
            log("Couldn't load the `\(childName)` child module into memory because it couldn't be built",
                category: "ModuleManagement",
                level: .error)
            return false
        }
        let childIsLoaded = load(builtChild)
        return childIsLoaded
    }
    
    /// Loads the given module into memory if possible.
    ///
    /// After the given module is loaded it will become a child.
    /// - Returns: `True` if the given module was loaded successfully; otherwise, `false`.
    private func load(_ child: RAModule) -> Bool {
        guard children[child.name].isNil else { return false }
        let dependency = dataSource.dependency(forChildModuleWithName: child.name)
        let childIsLoaded = child.load(
            byInjecting: dependency,
            andAddingToModuleTree: { attach(child) }
        )
        return childIsLoaded
    }
    
    private func unloadAllChildren() -> Void {
        for child in children { unload(child) }
    }
    
    /// Unloads the given module from memory.
    private func unload(_ child: RAModule) -> Void {
        guard children[child.name].hasValue else { return }
        child.unload(byRemovingFromModuleTree: { detach(child)} )
    }
    
    /// Adds the given module to children by its name.
    private func attach(_ child: RAModule) -> Void {
        children[child.name] = child
        child.parent = self
    }
    
    /// Removes the given module from children by its name.
    private func detach(_ child: RAModule) -> Void {
        children.removeValue(forKey: child.name)
        child.parent = nil
    }
    
    /// Builds a specific child module by its associated name if possible.
    private func buildChildModule(byName childName: String) -> RAModule? {
        guard let builder else {
            log("Couldn't build the `\(childName)` child module because this module didn't have a builder",
                category: "ModuleManagement",
                level: .error)
            return nil
        }
        let builtModule = builder.buildChildModule(byName: childName)
        return builtModule
    }
    
    
    // MARK: - Configuration
    
    // MARK: Setuping and Cleaning
    
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
    
    /// Performs internal setup for this module before it starts working by calling the setup method of this module and its inner components.
    private func _setup() -> Void {
        setup() // Should be called first
        builder?._setup()
        router._setup()
        view?._setup()
        interactor._setup()
    }
    
    /// Performs internal clean for this module after it stops working by calling the setup method of this module and its inner components.
    private func _clean() -> Void {
        interactor._clean()
        view?._clean()
        router._clean()
        builder?._clean()
        clean() // Should be called last
    }
    
    
    // MARK: Assembly and Disassembly
    
    /// Assembles this module by connecting its components to each other and to itself.
    private func assemble() -> Void {
        router.viewController = view
        view?._interactor = interactor
        interactor._router = router
        interactor._view = view
        interactor.module = self
        router.module = self
        view?.module = self
    }
    
    /// Disassembles this module by disconnecting components from each other and from itself.
    private func disassemble() -> Void {
        router.viewController = nil
        view?._interactor = nil
        interactor._router = nil
        interactor._view = nil
        interactor.module = nil
        router.module = nil
        view?.module = nil
    }
    
    
    // MARK: - Lifecycle
    
    /// Loads this module by configurating it.
    ///
    /// Called when this module is in the process of being added to the module tree.
    /// - Parameter attachToModuleTree: The closure that is called before this module is assembled and setup.
    /// - Returns: `True` if the module was loaded successfully; otherwise, `false`.
    internal final func load(byInjecting dependency: RADependency?, andAddingToModuleTree attachToModuleTree: () -> Void) -> Bool {
        let moduleCanBeLoaded = lifecycleDelegate.moduleShouldLoad(byInjecting: dependency)
        guard moduleCanBeLoaded else {
            log("Couldn't be loaded because of the lack of the necessary dependency",
                category: "ModuleLifecycle",
                level: .error)
            return false
        }
        attachToModuleTree() // Should be executed before any actions
        assemble()
        _setup()
        isLoaded = true
        embedChildModulesIfNeeded()
        log("Loaded into memory", category: "ModuleLifecycle")
        lifecycleDelegate.moduleDidLoad()
        return true
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
    
    /// Unloads this module by deconfigurating it.
    ///
    /// Called when this module is in the process of being removed from the module tree.
    /// - Parameter detachFromModuleTree: The closure that is called after this module is cleaned and disassembled.
    internal final func unload(byRemovingFromModuleTree detachFromModuleTree: () -> Void) -> Void {
        lifecycleDelegate.moduleWillUnload()
        unloadAllChildren()
        _clean()
        isLoaded = false
        disassemble()
        detachFromModuleTree()
        log("Unloaded from memory", category: "ModuleLifecycle")
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
        lifecycleDelegate = interactor
        dataSource = interactor
        RALeakDetector.register(self)
    }
    
    deinit {
        log("Deleted", category: "ModuleLifecycle")
    }
    
}



/// The methods adopted by the object you use to provide data for a specifc module.
public protocol RAModuleDataSource where Self: RAAnyObject {
    
    /// Provides a dependency for a specific child module when it loads into memory.
    func dependency(forChildModuleWithName childName: String) -> RADependency?
    
    /// Provides a context for a specific child module when it starts.
    func context(forChildModuleWithName childName: String) -> RAContext?
    
}



/// The methods adopted by the object you use to manage the lifecycle of a specific module.
public protocol RAModuleLifecycleDelegate where Self: RAAnyObject {
    
    /// Asks the delegate with what dependency it should be loaded.
    func moduleShouldLoad(byInjecting dependency: RADependency?) -> Bool
    
    /// Notifies the delegate that the module is loaded into the parent memory.
    func moduleDidLoad() -> Void
    
    /// Asks the delegate with what context it should be started.
    func moduleShouldStart(within context: RAContext?) -> Bool
    
    /// Notifies the delegate that the module is started.
    func moduleDidStart() -> Void
    
    /// Notifies the delegate that the module is about to be suspended.
    func moduleWillSuspend() -> Void
    
    /// Notifies the delegate that the module is suspended.
    func moduleDidSuspend() -> Void
    
    /// Notifies the delegate that the module is about to be resumed.
    func moduleWillResume() -> Void
    
    /// Notifies the delegate that the module is resumed.
    func moduleDidResume() -> Void
    
    /// Asks the delegate if there will be any result when the module stops its work.
    func moduleShouldStop() -> RAResult?
    
    /// Notifies the delegate that the module is stopped.
    func moduleDidStop() -> Void
    
    /// Notifies the delegate that the module is about to be unloaded from the parent memory.
    func moduleWillUnload() -> Void
    
}



internal final class RAStubModule: RAModule {
    
    internal init() {
        super.init(name: "Stub", interactor: RAStubInteractor(), router: RAStubRouter())
    }
    
}
