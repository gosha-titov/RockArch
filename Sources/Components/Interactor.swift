open class RAInteractor: RAComponent, RAIntegratable, RAModuleLifecycleDelegate, RAModuleDataProvider, RAModuleDataHandler {
    
    // MARK: - Properties
    
    /// A module into which this interactor is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this interactor.
    internal weak var _module: RAModule?
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Interactor" value.
    public let type: String = "Interactor"
    
    /// An internal router of this module.
    internal weak var _router: RARouter?
    
    /// An internal view of this module.
    internal weak var _view: (any RAView)?
    
    
    // MARK: - Module Data Handler
    
    /// Called when a specific interactor from the module tree passes some named value.
    ///
    /// Override this method to process the passed data.
    /// You don't need to call the `super` method.
    public func global(_ moduleName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a parent interactor passes some named data.
    ///
    /// Override this method to handle the passed data.
    /// You don't need to call the `super` method.
    public func parent(_ parentName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a specific child interactor passes some named data.
    ///
    /// Override this method to handle this passed data.
    /// You don't need to call the `super` method.
    public func child(_ childName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a specific child interactor completes its work and passes some result.
    ///
    /// This method is always called immediately after the child module has been hidden from the screen.
    /// For example, you can use this method to run the next child module:
    ///
    ///     override func child(_ childName: String, didCompleteWith result: RAResult?) -> Void {
    ///         switch childName:
    ///         case "Auth": router.showChildModule(byName: "Main", animated: true)
    ///         case "Main": router.showChildModule(byName: "Auth", animated: true)
    ///         default: return
    ///     }
    ///
    /// Override this method to handle this passed data and/or to start another child module.
    /// You don't need to call the `super` method.
    public func child(_ childName: String, didCompleteWith result: RAResult?) -> Void {}
    
    
    // MARK: - Module Data Provider
    
    /// Called when the module of this interactor loads a specific child module into memory.
    ///
    /// If a child module needs a dependency in order to be loaded, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func dependency(forChildModuleWithName childName: String) -> RADependency? {
    ///         switch childName {
    ///         case "Feed": return service1
    ///         case "Chat": return service2
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method.
    /// - Returns: A necessary dependency for a child module to be loaded.
    open func dependency(forChildModuleWithName childName: String) -> RADependency? { nil }
    
    /// Called when the module of this interactor starts a specific child module.
    ///
    /// If a child module needs a context in order to be started, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func context(forChildModuleWithName childName: String) -> RAContext? {
    ///         switch childName {
    ///         case "Community": return communityID
    ///         case "FriendProfile": return friendID
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method.
    /// - Returns: A necessary context for a child module to be started.
    open func context(forChildModuleWithName childName: String) -> RAContext? { nil }
    
    /// Called when the module of this interactor completed its work.
    ///
    /// Override this method to pass the work result of this module to a parent interactor.
    /// You don't need to call the `super` method.
    open func result() -> RAResult? { nil }
    
    
    // MARK: - Module Lifecycle Delegate
    
    /// Called when the module is about to be loaded into memory.
    ///
    /// This method is called when a parent module provides a dependency with which this module will be loaded.
    ///
    /// It's a built-in support the DI pattern in order to make implicit dependencies explicit.
    /// It also simplifies the testing of the module, because you don't need a real service, but only a stub one.
    /// The parent module of this provides these dependencies.
    ///
    /// You override this method to perform additional initialization on your private dependencies, such as services,
    /// then return a boolean value as an indicator that the module can be loaded.
    /// For example:
    ///
    ///     let service: ServiceInterface!
    ///
    ///     override func moduleCanLoad(with dependency: RADependency?) -> Bool {
    ///         guard let service = dependency as? ServiceInterface else {
    ///             return false
    ///         }
    ///         self.service = service
    ///         return true
    ///     }
    ///
    /// You don't need to call the `super` method.
    ///
    /// - Note: Returning `false` you indicate that the module cannot be loaded because you didn't get the necessary dependency.
    /// That is, this module will not be loaded into the parent memory. The parent module will continue its work. You will see the error in log messages.
    /// - Returns: `True` if the module can be loaded into the parent memory; otherwise, `false`.
    open func moduleCanLoad(with dependency: RADependency?) -> Bool { true }
    
    /// Called after the module is loaded into the parent memory.
    ///
    /// This method is called after a parent module has loaded this module into its memory
    /// and after setup methods of all components are called.
    /// That is, the module and its components are ready to work.
    ///
    /// You usually override this method, for example, to start fetching user data.
    /// You don't need to call the `super` method.
    open func moduleDidLoad() -> Void {}
    
    /// Called when the module is about to be started.
    ///
    /// This method is when a parent module provides a context within which this module will be started.
    ///
    /// You override this method to additionally configure the module, to perform custom tasks associated with working the module.
    /// Then return a boolean value as an indicator that the module can be started.
    /// You don't need to call the `super` method.
    ///
    /// - Note: Returning `false` you indicate that the module cannot be started because you didn't get the necessary context.
    /// That is, this module will not be started, therefore, it will not be shown. The parent will continue its work.
    /// You will see the error in log messages.
    /// - Returns: `True` if the module can be started; otherwise, `false`.
    open func moduleCanStart(with context: RAContext?) -> Bool { true }
    
    /// Called when the module is about to be started.
    ///
    /// This method is called before the view of this module appears.
    /// You don't need to call the `super` method.
    open func moduleWillStart() -> Void {}
    
    /// Called when the module has become active.
    ///
    /// This method is called afted the view of this module appeared.
    /// You don't need to call the `super` method.
    open func moduleDidStart() -> Void {}
    
    /// Called when the module is about to be stopped.
    ///
    /// This method is called before the view of this module disappears.
    /// You don't need to call the `super` method.
    open func moduleWillStop() -> Void {}
    
    /// Called when the module has become inactive.
    ///
    /// This method is called afted the view of this module disappeared.
    /// You don't need to call the `super` method.
    open func moduleDidStop() -> Void {}
    
    /// Called when the module is about to be unloaded from parent memory.
    ///
    /// You don't need to call the `super` method.
    open func moduleWillUnload() -> Void {}
    
    
    // MARK: - Lifecycle
    
    /// Setups this interactor before it starts working.
    ///
    /// This method is called when the module into which this interactor integrated is assembled and loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this interactor after it stops working.
    ///
    /// This method is called when the module into which this interactor integrated is about to be unloaded from the module tree and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    
    // MARK: - Init and Deinit
    
    /// Creates an interactor instance.
    public init() {
        RALeakDetector.register(self)
    }
    
    deinit {
        RALeakDetector.release(self)
    }
    
}
