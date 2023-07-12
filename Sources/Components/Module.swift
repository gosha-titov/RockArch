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
    
    /// The flag that indicates that the module behavior depends on its embedded child modules.
    ///
    /// If behavior depends on them and one of these embedded child modules cannot be loaded or started,
    /// then this module cannot be loaded or started too.
    public var behaviorDependsOnEmbeddedModules = false
    
    
    // MARK: Relatives
    
    /// The root module of the application.
    internal private(set) static var root: RAModule? = nil
    
    /// A parent module that owns this module, or `nil`.
    internal weak var parent: RAModule?
    
    /// The dictionary that stores created (and loaded) child modules by their names.
    private var children = [String: RAModule]()
    
    /// The child modules embedded in this module.
    private var embeddedChildren: [String: RAModule] {
        return children.filter { namesOfEmbeddedChildModules.contains($0.key) }
    }
    
    /// The names of the child modules embedded in this module.
    public private(set) var namesOfEmbeddedChildModules = [String]()
    
    /// The built child modules that should be embedded during the loading of this module.
    private var builtChildrenThatShouldBeEmbedded = [String: RAModule]()
    
    /// The names of the child modules that should be embedded during the loading of this module.
    private var namesOfChildrenThatShouldBeEmbedded = [String]()
    
    
    
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
    
    
    // MARK: - Starting and Stoping Modules
    
    /// Starts the given child module with the option to suspend this module.
    /// - Parameter moduleShouldBeSuspended: The flag that indicates that this module will be suspended during the starting of the child module.
    /// - Note: The child module should be loaded and inactive before being started.
    /// - Returns: `True` if the child module has been started; otherwise, `false`.
    @discardableResult
    private func start(_ child: RAModule, bySuspendingThisModule moduleShouldBeSuspended: Bool) -> Bool {
        guard child.isLoaded else {
            log("Couldn't start the `\(child.name)` child module because it wasn't loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard child.isInactive else {
            log("Couldn't start the `\(child.name)` child module because it was already started",
                category: .moduleManagement,
                level: .warning)
            return false
        }
        
        // Asks the child delegate if its module can be started
        let context = dataSource.context(forChildModuleWithName: child.name)
        let childCanStart = child.canStart(within: context)
        guard childCanStart else {
            log("Couldn't start the `\(child.name)` child module",
                category: .moduleManagement, level: .error)
            return false
        }
        
        if moduleShouldBeSuspended { willSuspend() }
        child.willStart()
        if moduleShouldBeSuspended { suspend() }
        child.start()
        child.didStart()
        if moduleShouldBeSuspended { didSuspend() }
        
        return true
    }
    
    
    // MARK: - Loading Modules
    
    /// Loads a specific child module into memory by its associated name.
    ///
    /// The loading process represents the building of the child module, attaching it to the module tree by adding it to children of this module and configuring it.
    /// - Returns: `True` if the given module was loaded successfully; otherwise, `false`.
    internal final func loadChild(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't load the `\(childName)` child module because this module wasn't loaded into memory",
                category: .moduleManagement, level: .error)
            return false
        }
        let childDoesNotExist = children[childName].isNil
        guard childDoesNotExist else {
            log("Couldn't load the `\(childName)` child module because it was already loaded into memory",
                category: .moduleManagement, level: .warning)
            return false
        }
        guard let builtChild = buildChild(byName: childName) else {
            log("Couldn't load the `\(childName)` child module into memory because it couldn't be built",
                category: .moduleManagement, level: .error)
            return false
        }
        let childIsLoaded = load(builtChild)
        return childIsLoaded
    }
    
    
    /// Unloads a specific child module from memory by its associated name.
    ///
    /// The unloading process represents the detaching the given module from the module tree by removing it from children of this module and deconfiguring it.
    /// - Note: The child module should be inactive before being unloaded.
    /// - Returns: `True` if the child module has been unloaded from memory; otherwise, `false`.
    internal final func unloadChild(byName childName: String) -> Bool {
        guard let child = children[childName] else {
            log("Couldn't unload the `\(childName)` child module because there's no loaded module with this name",
                category: .moduleManagement, level: .warning)
            return false
        }
        guard child.isInactive else {
            log("Couldn't unload the `\(childName)` child module because it's active or suspended",
                category: .moduleManagement, level: .error)
            return false
        }
        let childIsUnloaded = unload(child)
        return childIsUnloaded
    }
    
    /// Loads the given module into memory by attaching it to the module tree.
    ///
    /// The loading process represents the attaching the given module to the module tree by adding it to children of this module.
    /// - Parameter child: The module that will become a child of this module during the loading process.
    /// - Returns: `True` if the given module was loaded successfully; otherwise, `false`.
    private func load(_ child: RAModule) -> Bool {
        let childDoesNotExist = children[child.name].isNil
        guard childDoesNotExist else {
            log("Couldn't load the `\(child.name)` child module because it was already in the module tree",
                category: .moduleManagement, level: .error)
            return false
        }
        let dependency = dataSource.dependency(forChildModuleWithName: child.name)
        guard child.canLoad(byInjecting: dependency) else {
            log("Couldn't load the `\(child.name)` child module",
                category: .moduleManagement, level: .error)
            return false
        }
        attach(child)
        child.load()
        child.didLoad()
        return true
    }
    
    /// Unloads the given module from memory.
    ///
    /// The unloading process represents the detaching the given module from the module tree by removing it from children of this module and deconfiguring it.
    /// - Parameter child: The module that will no longer be a child of this module during the unloading process.
    /// - Returns: `True` if the given module was unloaded successfully; otherwise, `false`.
    private func unload(_ child: RAModule) -> Bool {
        let childExists = children[child.name].hasValue
        guard childExists else {
            log("Couldn't unload the `\(child.name)` child module from the module tree because it was not in it",
                category: .moduleManagement, level: .warning)
            return false
        }
        child.willUnload()
        child.unload()
        detach(child)
        return true
    }
    
    
    // MARK: Attaching / Detaching and Building
    
    /// Adds the given module to children of this module by its name if possible.
    private func attach(_ child: RAModule) -> Void {
        children[child.name] = child
        child.parent = self
    }
    
    /// Removes the given module from children of this module by its name if possible.
    private func detach(_ child: RAModule) -> Void {
        children.removeValue(forKey: child.name)
        child.parent = nil
    }
    
    /// Builds a specific child module by its associated name if possible.
    private func buildChild(byName childName: String) -> RAModule? {
        guard let builder else {
            log("Couldn't build the `\(childName)` child module because this module didn't have a builder",
                category: .moduleManagement, level: .error)
            return nil
        }
        guard let builtModule = builder.buildChildModule(byName: childName) else {
            return nil
        }
        return builtModule
    }
    
    
    // MARK: - Embedding
    
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
    /// - Note: The embedded child module becomes built and loaded only during the loading of this module.
    /// That is, this method should be called in the `setup()` method, because it's called
    public final func embedChildModule(byName childName: String) -> Void {
        guard isLoaded == false else {
            log("Couldn't embed the `\(childName)` child module because this module was loaded",
                category: .moduleManagement,
                level: .error)
            return
        }
        guard namesOfChildrenThatShouldBeEmbedded.contains(childName) == false else {
            log("Couldn't embed the `\(childName)` child module twice",
                category: .moduleManagement,
                level: .warning)
            return
        }
        namesOfChildrenThatShouldBeEmbedded.append(childName)
    }
    
    /// Embeds child modules that were built by attaching and loading them.
    private func embedChildren() -> Void {
        builtChildrenThatShouldBeEmbedded.values.forEach { attach($0) }
        namesOfEmbeddedChildModules = builtChildrenThatShouldBeEmbedded.map { $0.key }
        embeddedChildren.values.forEach { $0.load() }
    }
    
    
    // MARK: - Lifecycle
    
    // MARK: Loading
    
    /// Asks this module if it can be loaded with the given dependency.
    ///
    /// - Note: If the module behavior depends on its embedded child modules and one of these modules cannot be built or loaded,
    /// then this module cannot be loaded too.
    /// - Returns: `True` if module can be loaded; otherwise, `false`.
    internal final func canLoad(byInjecting dependency: RADependency?) -> Bool {
        
        // 1. Build modules that should be embedded
        for childName in namesOfChildrenThatShouldBeEmbedded {
            if let builtChild = buildChild(byName: childName) {
                builtChildrenThatShouldBeEmbedded[childName] = builtChild
            } else {
                guard behaviorDependsOnEmbeddedModules == false else {
                    log("Couldn't be loaded because the `\(childName)` embedded module wasn't built",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
            }
        }
        
        // 2. Ask the children delegats if their modules can be loaded
        for child in builtChildrenThatShouldBeEmbedded.values {
            let dependency = dataSource.dependency(forChildModuleWithName: child.name)
            let childCanLoad = child.canLoad(byInjecting: dependency)
            if childCanLoad == false {
                guard behaviorDependsOnEmbeddedModules == false else {
                    log("Couldn't be loaded because one of the embedded modules wasn't loaded",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
                builtChildrenThatShouldBeEmbedded.removeValue(forKey: child.name)
            }
        }
            
        // 3. Ask the delegate of this module if it can be loaded
        let thisModuleCanLoad = lifecycleDelegate.moduleCanLoad(byInjecting: dependency)
        guard thisModuleCanLoad else {
            log("Couldn't be loaded because this module didn't get necessary dependency",
                category: .moduleLifecycle, level: .error)
            return false
        }
        
        return true
    }
    
    /// Loads this module and its embedded child modules.
    ///
    /// Called when this module is in the process of being added to the module tree by the parent module.
    internal final func load() -> Void {
        isLoaded = true
        embedChildren()
        log("Loaded into memory", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are loaded into the parent memory.
    internal final func didLoad() -> Void {
        embeddedChildren.values.forEach { $0.didLoad() }
        lifecycleDelegate.moduleDidLoad()
    }
    
    
    // MARK: Starting
    
    /// Asks this module if it can be started within the given context.
    ///
    /// - Note: If the module behavior depends on its embedded child modules and one of these modules cannot be started,
    /// then this module cannot be started too.
    /// - Returns: `True` if module can be started; otherwise, `false`.
    internal final func canStart(within context: RAContext?) -> Bool {
        
        // 1. Ask the children delegats if their modules can be started
        for child in embeddedChildren.values {
            let context = dataSource.context(forChildModuleWithName: child.name)
            let childCanStart = child.canStart(within: context)
            if childCanStart == false {
                guard behaviorDependsOnEmbeddedModules == false else {
                    log("Couldn't be started because the `\(child.name)` embedded child module couldn't be started",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
            }
        }
        
        // 2. Ask the delegate of this module if it can be started
        let thisModuleCanStart = lifecycleDelegate.moduleCanStart(within: context)
        guard thisModuleCanStart else {
            log("Couldn't be started because this module didn't get the necessary context",
                category: .moduleLifecycle, level: .error)
            return false
        }
        
        return true
    }
    
    
    /// Notifies this module and its embedded children that they are about to be started.
    internal final func willStart() -> Void {
        embeddedChildren.values.forEach { $0.willStart() }
        lifecycleDelegate.moduleWillStart()
    }
    
    /// Starts this module and its embedded child modules by making all of them active.
    internal final func start() -> Void {
        embeddedChildren.values.forEach { $0.start() }
        state = .active
        log("Started working", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are started.
    internal final func didStart() -> Void {
        embeddedChildren.values.forEach { $0.didStart() }
        lifecycleDelegate.moduleDidStart()
    }
    
    
    // MARK: Suspending
    
    /// Notifies this module and its embedded children that they are about to be suspended.
    internal final func willSuspend() -> Void {
        embeddedChildren.values.forEach { $0.willSuspend() }
        lifecycleDelegate.moduleWillSuspend()
    }
    
    /// Suspends this module and its embedded child modules by making all of them suspended.
    ///
    /// Called when this module starts a child module.
    internal final func suspend() -> Void {
        embeddedChildren.values.forEach { $0.suspend() }
        state = .suspended
        log("Suspended working", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are suspended.
    internal final func didSuspend() -> Void {
        embeddedChildren.values.forEach { $0.didSuspend() }
        lifecycleDelegate.moduleDidSuspend()
    }
    
    
    // MARK: Resuming
    
    /// Notifies this module and its embedded children that they are about to be resumed.
    internal final func willResume() -> Void {
        embeddedChildren.values.forEach { $0.willResume() }
        lifecycleDelegate.moduleWillResume()
    }
    
    /// Called when a child module stops its work.
    internal final func resume() -> Void {
        embeddedChildren.values.forEach { $0.resume() }
        state = .active
        log("Resumed working", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are resumed.
    internal final func didResume() -> Void {
        embeddedChildren.values.forEach { $0.didResume() }
        lifecycleDelegate.moduleDidResume()
    }
    
    
    // MARK: Stopping
    
    /// Notifies this module and its embedded children that they are about to be stopped.
    internal final func willStop() -> Void {
        embeddedChildren.values.forEach { $0.willStop() }
        lifecycleDelegate.moduleWillStop()
    }
    
    /// Called when this module should stop its work for some reason.
    internal final func stop() -> Void {
        embeddedChildren.values.forEach { $0.stop() }
        state = .inactive
        log("Stopped working", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are stopped.
    internal final func didStop() -> Void {
        embeddedChildren.values.forEach { $0.didStop() }
        lifecycleDelegate.moduleDidStop()
    }
    
    
    // MARK: Unloading
    
    /// Notifies this module and its embedded children that they are about to be unloaded.
    internal final func willUnload() -> Void {
        children.values.forEach { $0.willUnload() }
        lifecycleDelegate.moduleWillUnload()
    }
    
    /// Unloads this module by deconfigurating it.
    ///
    /// Called when this module is in the process of being removed from the module tree.
    internal final func unload() -> Void {
        children.values.forEach { $0.unload() }
        _clean()
        disassemble()
        isLoaded = false
        state = .inactive
        log("Unloaded from memory", category: .moduleLifecycle)
    }
    
    
    // MARK: - Assembly and Disassembly
    
    /// Assembles this module by connecting its inner components to each other and to itself.
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
    
    
    // MARK: Setuping and Cleaning
    
    /// Setups this module before it starts working.
    ///
    /// This method is called when this module is assembled but not yet loaded into memory.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() {}
    
    /// Cleans this module after it stops working.
    ///
    /// This method is called when this module is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() {}
    
    /// Performs internal setup for this module before it starts working by calling setup methods of this module and its inner components.
    private func _setup() -> Void {
        setup()
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
        clean()
        children.removeAll()
        namesOfEmbeddedChildModules.removeAll()
        namesOfChildrenThatShouldBeEmbedded.removeAll()
        builtChildrenThatShouldBeEmbedded.removeAll()
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
    /// If this module doesn't have child modules, then pass `nil` (default).
    ///
    public init(name: String, interactor: RAInteractor, router: RARouter, view: (any RAView)? = nil, builder: RABuilder? = nil) {
        self.name = name
        self.interactor = interactor
        self.router = router
        self.view = view
        self.builder = builder
        lifecycleDelegate = interactor
        dataSource = interactor
        log("Created", category: .moduleLifecycle)
        
        RALeakDetector.register(self)
        
        // Configuring
        assemble()
        _setup()
    }
    
    
    deinit {
        log("Deleted", category: .moduleLifecycle)
    }
    
}



/// The methods adopted by the object you use to provide data for a specific module.
public protocol RAModuleDataSource where Self: RAAnyObject {
    
    /// Provides a dependency for a specific child module when it loads into memory.
    func dependency(forChildModuleWithName childName: String) -> RADependency?
    
    /// Provides a context for a specific child module when it starts.
    func context(forChildModuleWithName childName: String) -> RAContext?
    
    /// Provides a result of the work of the module.
    func result() -> RAResult?
    
}


/// The methods adopted by the object you use to manage the lifecycle of a specific module.
public protocol RAModuleLifecycleDelegate where Self: RAAnyObject {
    
    /// Asks the delegate with what dependency it can be loaded into the parent memory.
    func moduleCanLoad(byInjecting dependency: RADependency?) -> Bool
    
    /// Notifies the delegate that the module is loaded into the parent memory.
    func moduleDidLoad() -> Void
    
    /// Asks the delegate with what context it can be started.
    func moduleCanStart(within context: RAContext?) -> Bool
    
    /// Notifies the delegate that the module is about to be started.
    func moduleWillStart() -> Void
    
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
    
    /// Notifies the delegate that the module is about to be stopped.
    func moduleWillStop() -> Void
    
    /// Notifies the delegate that the module is stopped.
    func moduleDidStop() -> Void
    
    /// Notifies the delegate that the module is about to be unloaded from the parent memory.
    func moduleWillUnload() -> Void
    
}
