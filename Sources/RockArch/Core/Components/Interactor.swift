open class RAInteractor: RAAbstractInteractor {
    
}


open class RAAbstractInteractor: RAComponentIntegratedIntoModule, RAModuleLifecycleDelegate, RAModuleDataSource {
    
    // MARK: - Public Properties
    
    /// A module to that this builder belongs.
    public weak var module: RAModule?
    
    /// The string that has the "Interactor" value.
    public let type: String = "Interactor"
    
    /// A boolean value that indicates whether a parent module should keep the module loaded after its completion.
    public var moduleShouldBeLoadedIfCompleted = false
    
    
    // MARK: Internal Properties
    
    /// An internal router that is set by a module.
    internal weak var _router: RARouter?
    
    /// An internal view that is set by a module.
    internal weak var _view: (any RAView)?
    
    
    // MARK: - Interactions with Relatives
    
    /// Called when a specific child interactor passes some outcome.
    ///
    /// Override this method to process the passed data.
    /// You don't need to call the `super` method.
    open func child(_ child: String, didPassOutcome outcome: RAOutcome) -> Void {}
    
    /// Called when a specific child interactor passes some named value.
    ///
    /// Override this method to process the passed data.
    /// You don't need to call the `super` method.
    open func child(_ child: String, didPassValue value: Any, withLabel label: String) -> Void {}
    
    /// Called when a parent interactor passes some named value.
    ///
    /// Override this method to process the passed data.
    /// You don't need to call the `super` method.
    open func parent(didPassValue value: Any, withLabel label: String) -> Void {}
    
    /// Passes some named value to a specific related interactor.
    ///
    /// You can pass any named value to a parent/child interactor as in the following example:
    ///
    ///     pass(value: chosenColor, withLabel: "chosen_color", to: .parent)
    ///
    /// - Returns: `True` if the named value has been passed and a specific related interactor has received it; otherwise, `false`.
    @discardableResult
    public final func pass(value: Any, withLabel label: String, to receiver: RARelative) -> Bool {
        guard let module else {
            let labelOrEmpty = label.isEmpty ? "" : " `\(label)`"
            log("Couldn't pass the\(labelOrEmpty) value to the \(receiver) because this interactor doesn't belong to any module",
                category: .moduleCommunication,
                level: .error)
            return false
        }
        let signal = RASignal(label: label, value: value)
        return module.send(signal, to: receiver)
    }
    
    
    // MARK: - Casting Relatives
    
    /// Returns an instance of a parent interactor casted to the given interface.
    ///
    /// You usually use this method when it's not enough for you to simply pass/receive some data to/from a parent interactor,
    /// so you create an individual communication interface to the parent interactor.
    /// Then you define a computed property as in the example below:
    ///
    ///     var parent: SomeInterface? {
    ///         return parent(as: SomeInterface.self)
    ///     }
    ///
    /// For example, this interactor belongs to the `Profile` module and you need to interact with the `Settings` parent interactor:
    ///
    ///     var parent: ProfileToSettingsInterface? {
    ///         return parent(as: ProfileToSettingsInterface.self)
    ///     }
    ///
    /// - Note: You don't should storage this instance directly, because it can lead to implicit errors.
    /// - Returns: An instance of a parent interactor casted to the given interface; otherwise, `nil`.
    public final func parent<Interface>(as: Interface.Type) -> Interface? {
        guard let module else {
            log("Couldn't take the parent interactor because this interactor doesn't belong to the module",
                category: .moduleCommunication,
                level: .error)
            return nil
        }
        return module.interactor(of: .parent) as? Interface
    }
    
    /// Returns an instance of a specific child interactor casted to the given interface.
    ///
    /// You usually use this method when it's not enough for you to simply pass/receive some data to/from a specific child interactor,
    /// so you create an individual communication interface to this child interactor.
    /// Then you define a computed property as in the example below:
    ///
    ///     var someChild: SomeInterface? {
    ///         return child("Some", as: SomeInterface.self)
    ///     }
    ///
    /// For example, this interactor belongs to the `Settings` module and you need to interact with the `Profile` child interactor:
    ///
    ///     var profileModule: SettingsToProfileInterface? {
    ///         return child("Profile", as: SettingsToProfileInterface.self)
    ///     }
    ///
    /// - Note: You don't should storage this instance directly, because it can lead to implicit errors.
    /// - Returns: An instance of a specific child interactor casted to the given interface; otherwise, `nil`.
    public final func child<Interface>(_ child: String, as: Interface.Type) -> Interface? {
        guard let module else {
            log("Couldn't take the `\(child)` child interactor because this interactor doesn't belong to the module",
                category: .moduleCommunication,
                level: .error)
            return nil
        }
        return module.interactor(of: .child(child)) as? Interface
    }
    
    
    // MARK: - Module Data Source
    
    /// Called when the module of this interactor loads a specific child module into memory.
    ///
    /// If a child module needs a dependency in order to be loaded, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func dependency(for child: String) -> RADependency? {
    ///         switch child {
    ///         case "Settings": return SomeDependency(service1, service2)
    ///         case "Messages": return service3
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method.
    /// - Returns: A necessary dependency for loading a child module; otherwise, `nil`.
    open func dependency(for child: String) -> RADependency? {
        return nil
    }
    
    /// Called when the module of this interactor starts a specific child module.
    ///
    /// If a child module needs a context in order to be started, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func context(for child: String) -> RAContext? {
    ///         switch child {
    ///         case "Community": return communityID
    ///         case "Chat": return friendID
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method.
    /// - Returns: A necessary context for starting a child module; otherwise, `nil`.
    open func context(for child: String) -> RAContext? {
        return nil
    }
    
    
    // MARK: - Module Lifecycle Delegate
    
    /// Called when the module is about to be loaded into memory.
    ///
    /// This method is called before the parent module is about to add this module to the module hierarchy
    /// and before components of this module are configured to work.
    ///
    /// It's a built-in support the DI pattern in order to make implicit dependencies explicit.
    /// It also simplifies the testing of the module, because you don't need a real service, but only an imitation of it.
    /// The parent module of this provides these dependencies.
    ///
    /// You override this method to perform additional initialization on your private dependencies, such as services,
    /// then return a boolean value as an indicator that the module can be loaded.
    /// For example:
    ///
    ///     // Single Dependency
    ///     override func moduleShouldLoad(byInjecting dependency: RADependency?) -> Bool {
    ///         guard let service = dependency as? SomeServiceInterface else {
    ///             return false
    ///         }
    ///         self.service = service
    ///         return true
    ///     }
    ///
    ///     // Multiple Dependency
    ///     override func moduleShouldLoad(byInjecting dependency: RADependency?) -> Bool {
    ///         guard let container = dependency as? SomeDependencyContainer else {
    ///             return false
    ///         }
    ///         service1 = container.service1
    ///         service2 = container.service2
    ///         service3 = container.service3
    ///         return true
    ///     }
    ///
    /// You don't need to call the `super` method.
    ///
    /// - Note: Returning `false` you indicate that the module cannot be loaded because you didn't get the necessary dependency.
    /// That is, this module will not be loaded into the parent memory. The parent module will continue its work. You will see the error in log messages.
    ///
    /// - Returns: `True` if the module can be loaded into the parent memory; otherwise, `false`.
    ///
    open func moduleShouldLoad(byInjecting dependency: RADependency?) -> Bool {
        return true
    }
    
    /// Called after the module is loaded into parent memory.
    ///
    /// This method is called after a parent module has loaded this module into its memory.
    /// That is, the module and its components are assembled and configured, but ...
    ///
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func moduleDidLoad() -> Void {}
    
    /// Called when the module is about to be started.
    ///
    /// This method is called before the parent module is about to start this module passing context within which it starts.
    ///
    /// You override this method to additionally configure the module,
    /// to perform custom tasks associated with working the module, such as fetching some data from network services.
    /// Then return a boolean value as an indicator that the module can be started.
    /// You don't need to call the `super` method.
    ///
    /// - Note: Returning `false` you indicate that the module cannot be started because you didn't get the necessary context.
    /// That is, this module will not be started, therefore, it will not be shown. The parent will continue its work.
    /// You will see the error in log messages.
    ///
    /// - Returns: `True` if the module can be started; otherwise, `false`.
    ///
    open func moduleShouldStart(within context: RAContext?) -> Bool {
        return true
    }
    
    /// Called when the module has becomes active.
    ///
    /// This method is called when a parent module starts this module.
    /// The view of this module is just about to appear.
    ///
    /// You usually override this method to perform some logical tasks.
    /// You don't need to call the `super` method.
    open func moduleDidStart() -> Void {}
    
    /// Called when the module is about to be suspended.
    /// You don't need to call the `super` method.
    open func moduleWillSuspend() -> Void {}
    
    /// Called when the module has suspended its work.
    /// You don't need to call the `super` method.
    open func moduleDidSuspend() -> Void {}
    
    /// Called when the module is about to be resumed.
    /// You don't need to call the `super` method.
    open func moduleWillResume() -> Void {}
    
    /// Called when the module has resumed its work.
    /// You don't need to call the `super` method.
    open func moduleDidResume() -> Void {}
    
    /// Called when the module is about to be stopped.
    /// You don't need to call the `super` method.
    open func moduleShouldStop() -> RAOutcome? {
        return nil
    }
    
    /// Called when the module has stopped its work.
    /// You don't need to call the `super` method.
    open func moduleDidStop() -> Void {}
    
    /// Called when the module is about to be unloaded from parent memory.
    /// You don't need to call the `super` method.
    open func moduleWillUnload() -> Void {}
    
    
    // MARK: - Lifecycle
    
    /// Setups this interactor.
    ///
    /// This method is called when the module to which this interactor belongs is loaded into memory and assembled.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method.
    open func setup() -> Void {}
    
    /// Cleans this interactor.
    ///
    /// This method is called when the module to which this interactor belongs is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method.
    open func clean() -> Void {}
    
    /// Called when the module is loaded into memory and assembled.
    internal final func _setup() -> Void {
        defer { setup() }
        RALeakDetector.register(self)
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal final func _clean() -> Void {
        clean()
    }
    
    
    // MARK: - Internal Init
    
    /// Creates an interactor instance.
    fileprivate init() {}
    
}


/// An interactor that is marked as empty.
internal final class RAEmptyInteractor: RAAbstractInteractor, RAEmpty {
    
    internal override init() {
        super.init()
    }
    
}
