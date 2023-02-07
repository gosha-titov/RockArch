import UIKit

open class RAModule: RAComponent {
    
    /// The root module of the application.
    internal private(set) static var root: RAModule? = nil
    
    
    // MARK: - Public Properties
    
    /// A string associated with the name of this module.
    public let name: String
    
    /// The string that has the "Module" value.
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
    
    /// A boolean value that indicates whether a parent module should keep this module loaded when it becomes inactive.
    public final var shouldRemainLoadedIfCompleted: Bool {
        return interactor.moduleShouldRemainLoadedIfCompleted
    }
    
    
    // MARK: Internal Properties
    
    /// A parent module that owns this module, or `nil`.
    internal weak var parent: RAModule?
    
    /// The internal interactor of this module.
    internal let interactor: RAAbstractInteractor
    
    /// The internal router of this module.
    internal let router: RARouter
    
    /// The internal view of this module, or `nil`.
    internal let view: (any RAView)?
    
    /// The internal builder of this module, or `nil`.
    internal let builder: RABuilder?
    
    /// The object that provides the data for this module.
    internal let dataSource: RAModuleDataSource
    
    /// The object that acts as the lifecycle delegate of this module.
    internal let lifecycleDelegate: RAModuleLifecycleDelegate
    
    
    // MARK: Private Properties
    
    /// A dictionary that stores created (and loaded) child modules.
    private var children = [String: RAModule]()
    
    
    // MARK: - Child Interacting
    
    /// Sends a signal to a specific receiver if possible.
    internal final func send(_ signal: RASignal, to receiver: RARelative) -> Bool {
        let message: String
        let receivingModule: RAModule
        let sender: RARelative
        switch receiver {
        case .child(let childName):
            guard let child = children[childName] else {
                log("Couldn't send the \(signal) to the non-existent `\(childName)` child module",
                    category: .moduleInteracting,
                    level: .error)
                return false
            }
            message = "Sended the \(signal) to the \(childName) child module"
            receivingModule = child
            sender = .parent
        case .parent:
            guard let parent else {
                log("Couldn't send the \(signal) to the non-existent parent module",
                    category: .moduleInteracting,
                    level: .error)
                return false
            }
            message = "Sended the \(signal) to the `\(parent.name)` parent module"
            receivingModule = parent
            sender = .child(name)
        }
        log(message, category: .moduleInteracting)
        return receivingModule.receive(signal, from: sender)
    }
    
    /// Receives a signal from a specific sender if possible.
    fileprivate final func receive(_ signal: RASignal, from sender: RARelative) -> Bool {
        let message: String
        switch sender {
        case .child(let childName):
            guard children.hasKey(childName) else {
                log("Couldn't receive the \(signal) from the non-existent `\(childName)` child module",
                    category: .moduleInteracting,
                    level: .error)
                return false
            }
            interactor.child(childName, didPassValue: signal.value, withLabel: signal.label)
            message = "Received the \(signal) from the `\(childName)` child module"
        case .parent:
            guard let parent else {
                log("Couldn't receive the \(signal) from the non-existent parent module",
                    category: .moduleInteracting,
                    level: .error)
                return false
            }
            interactor.parent(didPassValue: signal.value, withLabel: signal.label)
            message = "Received the \(signal) from the `\(parent.name)` parent module"
        }
        log(message, category: .moduleInteracting)
        return true
    }
    
    /// Receives an outcome from a specific child.
    private func receiveOutcome(from child: RAModule) -> Void {
        if let outcome = child.lifecycleDelegate.moduleShouldStop() {
            log("Recieved an outcome from the `\(child.name)` child module",
                category: .moduleInteracting)
            interactor.child(child.name, didPassOutcome: outcome)
        }
    }
    
    /// Returns an interactor of a specific relative if possible.
    internal final func interactor(of relative: RARelative) -> RAAbstractInteractor? {
        let relatedInteractor: RAAbstractInteractor
        switch relative {
        case .child(let childName):
            guard let child = children[childName] else {
                log("Couldn't take an interactor from the non-existent `\(childName)` child module",
                    category: .moduleInteracting,
                    level: .error)
                return nil
            }
            relatedInteractor = child.interactor
        case .parent:
            guard let parent else {
                log("Couldn't take an interactor from the non-existent parent module",
                    category: .moduleInteracting,
                    level: .error)
                return nil
            }
            relatedInteractor = parent.interactor
        }
        return relatedInteractor
    }
    
    /// Returns a router of a specific relative if possible.
    internal final func router(of relative: RARelative) -> RARouter? {
        let relatedRouter: RARouter
        switch relative {
        case .child(let childName):
            guard let child = children[childName] else {
                log("Couldn't take a router from the non-existent `\(childName)` child module",
                    category: .moduleInteracting,
                    level: .error)
                return nil
            }
            relatedRouter = child.router
        case .parent:
            guard let parent else {
                log("Couldn't take a router from the non-existent parent module",
                    category: .moduleInteracting,
                    level: .error)
                return nil
            }
            relatedRouter = parent.router
        }
        return relatedRouter
    }
    
    
    // MARK: - Child Management
    
    /// Invokes a specific child module.
    ///
    /// This method transfers control to a specific child module, if possible.
    /// That is, this module becomes suspended, and a child module becomes active.
    ///
    /// - Returns: `True` if control has been transferred to a child module; otherwise, `false`.
    internal final func invokeChildModule(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't invoke the `\(childName)` child module because this module is not loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard isActive else {
            log("Couldn't invoke the `\(childName)` child module because this module is not active",
                category: .moduleManagement,
                level: .error)
            return false
        }
        let child: RAModule
        if let existingChild = children[childName] {
            child = existingChild
        } else {
            guard let builtChild = buildChildModule(byName: childName) else {
                log("Couldn't invoke the `\(childName)` child module because it cannot be built",
                    category: .moduleManagement,
                    level: .error)
                return false
            }
            guard load(builtChild) else {
                log("Couldn't invoke the `\(childName)` child module because it cannot be loaded into memory",
                    category: .moduleManagement,
                    level: .error)
                return false
            }
            child = builtChild
        }
        return start(child, shouldSuspendThisModule: true)
    }
    
    /// Revokes a specific child module.
    ///
    /// This method takes control away from a specific child module, if possible.
    /// That is, this module becomes resumed, and a child module becomes suspended or inactive.
    ///
    /// - Returns: `True` if control has been taken away from a child module; otherwise, `false`.
    internal final func revokeChildModule(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't revoke the `\(childName)` child module because this module is not loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard isSuspended else {
            log("Couldn't revoke the `\(childName)` child module because this module was not suspended",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard let child = children[childName] else {
            log("Couldn't revoke the `\(childName)` child module because it doesn't exist",
                category: .moduleManagement,
                level: .error)
            return false
        }
        return stop(child, shouldResumeThisModule: true)
    }
    
    
    // MARK: Starting and Stoping Children
    
    /// Starts a specific child module if possible.
    @discardableResult
    private func start(_ child: RAModule, shouldSuspendThisModule moduleSuspendsWork: Bool) -> Bool {
        guard child.isLoaded else {
            log("Couldn't start the `\(child.name)` child module because it's not loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard child.isInactive else {
            log("Couldn't start the `\(child.name)` child module because it's already started",
                category: .moduleManagement,
                level: .warning)
            return false
        }
        let context = dataSource.context(for: child.name)
        let childCanStart = child.lifecycleDelegate.moduleShouldStart(within: context)
        guard childCanStart else {
            log("Couldn't start the `\(child.name)` child module because it didn't get the necessary context",
                category: .moduleManagement,
                level: .error)
            return false
        }
        if moduleSuspendsWork {
            lifecycleDelegate.moduleWillSuspend()
            suspend()
        }
        child.start()
        child.lifecycleDelegate.moduleDidStart()
        if moduleSuspendsWork {
            lifecycleDelegate.moduleDidSuspend()
        }
        return true
    }
    
    /// Stops a specific child module if possible.
    @discardableResult
    private func stop(_ child: RAModule, shouldResumeThisModule moduleResumesWork: Bool) -> Bool {
        guard child.isLoaded else {
            log("Couldn't stop the `\(child.name)` child module because it's not loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard child.isActive || child.isSuspended else {
            log("Couldn't stop the `\(child.name)` child module because it's already inactive",
                category: .moduleManagement,
                level: .warning)
            return false
        }
        child.stopAllChildren()
        receiveOutcome(from: child)
        if moduleResumesWork {
            lifecycleDelegate.moduleWillResume()
        }
        child.stop()
        if moduleResumesWork {
            resume()
            lifecycleDelegate.moduleDidResume()
        }
        child.lifecycleDelegate.moduleDidStop()
        if child.shouldRemainLoadedIfCompleted == false {
            unload(child)
        }
        return true
    }
    
    /// Stops all child modules without resuming this module, recursively.
    internal final func stopAllChildren() -> Void {
        for child in children.values {
            // This calls the `stopAllChildren()` method of a child.
            stop(child, shouldResumeThisModule: false)
        }
    }
    
    
    // MARK: Loading and Unloading Children
    
    /// Preloads a specific child module into memory if possible.
    /// - Returns: `True` if the child module has been loaded into memory; otherwise, `false`.
    internal final func preloadChildModule(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't preload the `\(childName)` child module because this module is not loaded into memory",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard children[childName].isNil else {
            log("Couldn't preload the `\(childName)` child module because it's already loaded into memory",
                category: .moduleManagement,
                level: .warning)
            return false
        }
        guard let builtChild = buildChildModule(byName: childName) else {
            log("Couldn't preload the `\(childName)` child module because it cannot be built",
                category: .moduleManagement,
                level: .error)
            return false
        }
        return load(builtChild)
    }
    
    /// Unloads a specific child module from memory if possible.
    /// - Returns: `True` if the child module has been unloaded from memory; otherwise, `false`.
    internal final func unloadChildModule(byName childName: String) -> Bool {
        guard let child = children[childName] else {
            log("Couldn't unload the `\(childName)` child module because there's no loaded module with this name",
                category: .moduleManagement,
                level: .error)
            return false
        }
        guard child.isInactive else {
            log("Couldn't unload the `\(childName)` child module because it's active or suspended",
                category: .moduleManagement,
                level: .error)
            return false
        }
        unload(child)
        return true
    }
    
    /// Loads a specific module into memory if possible.
    private func load(_ child: RAModule) -> Bool {
        let dependency = dataSource.dependency(for: child.name)
        let childCanLoad = child.lifecycleDelegate.moduleShouldLoad(byInjecting: dependency)
        guard childCanLoad else {
            log("Couldn't load the `\(child.name)` child module because it didn't get the necessary dependency",
                category: .moduleManagement,
                level: .error)
            return false
        }
        attach(child)
        child.load()
        child.lifecycleDelegate.moduleDidLoad()
        return true
    }
    
    /// Unloads all children from memory.
    private func unloadAllChildren() -> Void {
        for child in children.values {
            unload(child)
        }
    }
    
    /// Unloads a specific module from memory.
    private func unload(_ child: RAModule) -> Void {
        child.lifecycleDelegate.moduleWillUnload()
        child.unload()
        detach(child)
    }
    
    
    // MARK: Attaching and Detaching Children
    
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
    
    
    // MARK: Building Children
    
    /// Builds a specific child module by its name if possible.
    private func buildChildModule(byName childName: String) -> RAModule? {
        guard let builder else {
            log("Couldn't build the `\(childName)` child module because this module doesn't have a builder",
                category: .moduleManagement,
                level: .error)
            return nil
        }
        let childModule = builder.build(by: childName)
        return (childModule is RAEmpty) ? nil : childModule
    }
    
    
    // MARK: - Assembly and Disassembly, Setuping and Cleaning
    
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
    
    /// Setups this module so that it's ready to work.
    private func setup() -> Void {
        builder?._setup()
        router._setup()
        view?._setup()
        interactor._setup()
    }
    
    /// Cleans this module so that it's ready to be deinited.
    private func clean() -> Void {
        interactor._clean()
        view?._clean()
        router._clean()
        builder?._clean()
    }
    
    
    // MARK: - Lifecycle
    
    /// Called when a parent module loads this module into its memory.
    internal final func load() -> Void {
        defer { log("Loaded into memory", category: .moduleLifecycle) }
        assemble()
        setup()
        isLoaded = true
    }
    
    /// Called when a parent module starts this module.
    internal final func start() -> Void {
        defer { log("Started working", category: .moduleLifecycle) }
        state = .active
    }
    
    /// Called when this module starts a child module.
    internal final func suspend() -> Void {
        defer { log("Suspended working", category: .moduleLifecycle) }
        state = .suspended
    }
    
    /// Called when a child module stops its work.
    internal final func resume() -> Void {
        defer { log("Resumed working", category: .moduleLifecycle) }
        state = .active
    }
    
    /// Called when this module should stop its work for some reason.
    internal final func stop() -> Void {
        defer { log("Stopped working", category: .moduleLifecycle) }
        state = .inactive
    }
    
    /// Called when a parent module unloads this module from its memory.
    internal final func unload() -> Void {
        defer { log("Unloaded from memory", category: .moduleLifecycle) }
        unloadAllChildren()
        clean()
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
    /// Implement this by creating a new class that conforms to the `RAView` protocol.
    /// If this is a logical module that doesn't have a view, then pass `nil` (default).
    ///
    /// - Parameter builder: The builder that is responsible for creating child modules by their associated names.
    /// Implement this by subclassing the `RABuilder` class.
    /// If this module don't have child modules, then pass `nil` (default).
    ///
    public init(name: String, interactor: RAAbstractInteractor, router: RARouter, view: (any RAView)? = nil, builder: RABuilder? = nil) {
        defer { log("Created", category: .moduleLifecycle) }
        self.name = name
        self.interactor = interactor
        self.router = router
        self.view = view
        self.builder = builder
        dataSource = interactor
        lifecycleDelegate = interactor
        RALeakDetector.register(self)
    }
    
    deinit {
        log("Deleted", category: .moduleLifecycle)
    }
    
}


/// The methods adopted by the object you use to provide data for a specifc module.
public protocol RAModuleDataSource where Self: RAObject {
    
    /// Provides a dependency for a specific child when it loads into memory.
    func dependency(for childName: String) -> RADependency?
    
    /// Provides a context for a specific child when it starts.
    func context(for childName: String) -> RAContext?
    
}


/// The methods adopted by the object you use to manage the lifecycle of a specific module.
public protocol RAModuleLifecycleDelegate where Self: RAObject {
    
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
    
    /// Asks the delegate if there will be any outcome when the module stops its work.
    func moduleShouldStop() -> RAOutcome?
    
    /// Notifies the delegate that the module is stopped.
    func moduleDidStop() -> Void
    
    /// Notifies the delegate that the module is about to be unloaded from parent memory.
    func moduleWillUnload() -> Void
    
}


/// A module that is marked as empty. That is, it cannot be added to the module tree.
final internal class RAEmptyModule: RAModule, RAEmpty {
    
    /// Creates an empty module.
    internal init() {
        super.init(name: "Empty", interactor: RAEmptyInteractor(), router: RAEmptyRouter())
    }
    
}
