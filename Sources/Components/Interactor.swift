/// An interactor that is responsible for all business logic of the module.
///
/// The `RAInteractor` class defines the shared behavior that’s common to all interactors.
/// You always define a new class that subclasses the `RAInteractor` class,
/// then override all logiсal methods necessary for: providing and handling module's data, managing its lifecycle, communicate with other interactors and so on.
///
/// In order to interact with the `view` component of the module, you use a specific communication interface.
/// This is in order to clearly delineate the work of the components and ensure clarity of interactions between them.
///
/// Pay attention, the router already has this built-in interface to showing and hiding child modules, to complete this module.
/// So you don't need to create and specify it.
///
/// The interactor has a lifecycle consisting of the `setup()` and `clean()` methods,
/// which are called when the module is attached to or detached from the module tree.
/// You can override these to perform additional initialization on your properties and, accordingly, to clean them.
///
/// - Note: Each component can log messages by calling the `log(_:category:level:)` method.
/// These messages are handled by the current black box with its loggers.
///
open class RAInteractor<ViewInterface>: RAAnyInteractor {
    
    /// A router that is responsible for the hierarchy of modules: showing and hiding child modules, completing the module.
    public final var router: RARouterInterface? { _router }
    
    /// A view that is responsible for configurating and updating UI, catching and handling user interactions.
    public final var view: ViewInterface? { _view as? ViewInterface }
    
    public override init() {
        super.init()
    }
    
}


/// An interactor that has implementations of the main properties and methods.
@MainActor
open class RAAnyInteractor: RAComponent, RAIntegratable, RAModuleLifecycleDelegate, RAModuleDataProvider, RAModuleDataHandler {
    
    /// A module into which this interactor is integrated.
    public final var module: RAModuleInterface? { _module }
    
    /// An internal module of this interactor.
    internal weak var _module: RAModule?
    
    /// The textual representation of the type of this object.
    ///
    /// This property has the "Interactor" value.
    public let type: String = "Interactor"
    
    /// An internal router of this module.
    internal weak var _router: RARouter?
    
    /// An internal view of this module.
    internal weak var _view: (any RAView)?
    
    
    // MARK: - Communication and Interaction
    
    /// Passes some named value to a specific module.
    ///
    /// You usually call this method as in the following example:
    ///
    ///     // Pass a current score to a parent module
    ///     pass(value: currentScore, withLabel: "current_score", to: .parent)
    ///
    ///     // Pass a new color scheme to all modules
    ///     pass(
    ///         value: ColorScheme.sunrise,
    ///         withLabel: "new_color_scheme",
    ///         to: .global(.all)
    ///     )
    ///
    /// - Returns: `True` if the receiver (or at least one of them) has handled this value; otherwise, `false`.
    @discardableResult
    public final func pass(value: Any, withLabel label: String, to receiver: RAReceiver) -> Bool {
        guard let module = _module else {
            log("Couldn't pass a value because this interactor didn't integrated into a module",
                category: .moduleCommunication, level: .error)
            return false
        }
        let signal = RASignal(label: label, value: value)
        return module.send(signal, to: receiver)
    }
    
    /// Returns an instance of a parent interactor casted to the given interface.
    ///
    /// You usually use this method when it's not enough for you to simply pass/handle some data to/from a parent interactor,
    /// so you create a communication interface to the parent interactor.
    /// Then you define a computed property as in the example below:
    ///
    ///     var parent: SomeInterface? {
    ///         return parent(as: SomeInterface.self)
    ///     }
    ///
    /// For example, this interactor belongs to the *Feed* module and you need to interact with the *Main* parent interactor:
    ///
    ///     var parent: FeedToMainInteractorInterface? {
    ///         return parent(as: FeedToMainInteractorInterface.self)
    ///     }
    ///
    /// - Note: You should not storage this instance directly, because it can lead to implicit errors.
    /// - Returns: An instance of a parent interactor casted to the given interface; otherwise, `nil`.
    public final func parent<Interface>(as: Interface.Type) -> Interface? {
        guard let module = _module else {
            log("Couldn't take a parent interactor because this interactor didn't integrated into a module",
                category: .moduleInteracting, level: .error)
            return nil
        }
        return module.interactor(of: .parent) as? Interface
    }
    
    /// Returns an instance of a specific child interactor casted to the given interface.
    ///
    /// You usually use this method when it's not enough for you to simply pass/handle some data to/from a specific child interactor,
    /// so you create a communication interface to this child interactor.
    /// Then you define a computed property as in the example below:
    ///
    ///     var someChild: SomeInterface? {
    ///         return child(SomeModule.name, as: SomeInterface.self)
    ///     }
    ///
    /// For example, this interactor belongs to the *Main* module and you need to interact with the *Feed* child interactor:
    ///
    ///     var feedChild: MainToFeedInteractorInterface? {
    ///         return child(FeedModule.name, as: MainToFeedInteractorInterface.self)
    ///     }
    ///
    /// - Note: You should not storage this instance directly, because it can lead to implicit errors.
    /// - Returns: An instance of a specific child interactor casted to the given interface; otherwise, `nil`.
    public final func child<Interface>(_ childName: String, as: Interface.Type) -> Interface? {
        guard let module = _module else {
            log("Couldn't take a child interactor because this interactor didn't integrated into a module",
                category: .moduleInteracting, level: .error)
            return nil
        }
        return module.interactor(of: .child(childName)) as? Interface
    }
    
    
    // MARK: - Module Data Handler
    
    /// Called when a specific interactor from the module tree passes some named value.
    ///
    /// Override this method to process the passed data.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func global(_ moduleName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a parent interactor passes some named data.
    ///
    /// Override this method to handle the passed data.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func parent(_ parentName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a specific child interactor passes some named data.
    ///
    /// Override this method to handle this passed data.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func child(_ childName: String, didPass value: Any, with label: String) -> Void {}
    
    /// Called when a specific child interactor completes its work and passes some result.
    ///
    /// This method is always called immediately after the child module has been hidden from the screen.
    /// For example, you can use this method to run the next child module:
    ///
    ///     override func child(_ childName: String, didCompleteWith result: RAResult?) -> Void {
    ///         switch childName:
    ///         case AuthModule.name: 
    ///             router.showChildModule(byName: MainModule.name, animated: true)
    ///         case MainModule.name:
    ///             router.showChildModule(byName: AuthModule.name, animated: true)
    ///         default:
    ///             return
    ///     }
    ///
    /// Override this method to handle this passed data and/or to start another child module.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func child(_ childName: String, didCompleteWith result: RAResult?) -> Void {}
    
    
    // MARK: - Module Data Provider
    
    /// Called when the module of this interactor loads a specific child module into memory.
    ///
    /// If a child module needs a dependency in order to be loaded, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func dependency(forChildModuleWithName childName: String) -> RADependency? {
    ///         switch childName {
    ///         case MessagesModule.name: return service
    ///         case SettingsModule.name: return storage
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method, because the default implementation does nothing.
    /// - Returns: A necessary dependency for a child module to be loaded.
    open func dependency(forChildModuleWithName childName: String) -> RADependency? { nil }
    
    /// Called when the module of this interactor starts a specific child module.
    ///
    /// If a child module needs a context in order to be started, you should pass it by overriding this method.
    /// For example:
    ///
    ///     override func context(forChildModuleWithName childName: String) -> RAContext? {
    ///         switch childName {
    ///         case FriendProfile.name: return friendID
    ///         case FullScreenImageModule.name: return image
    ///         default: return nil
    ///         }
    ///     }
    ///
    /// You don't need to call the `super` method, because the default implementation does nothing.
    /// - Returns: A necessary context for a child module to be started.
    open func context(forChildModuleWithName childName: String) -> RAContext? { nil }
    
    /// Called when the module of this interactor completed its work.
    ///
    /// Override this method to pass the work result of this module to a parent interactor.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func result() -> RAResult? { nil }
    
    
    // MARK: - Module Lifecycle Delegate
    
    /// Called after the module is loaded into the parent memory.
    ///
    /// This method is called after a parent module has loaded this module into its memory
    /// and after setup methods of all components are called.
    /// That is, the module and its components are ready to work.
    ///
    /// You usually override this method, for example, to start fetching user data.
    /// You don't need to call the `super` method, because the default implementation does nothing.
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
    /// You will see the error in log messages, because the default implementation does nothing.
    /// - Returns: `True` if the module can be started; otherwise, `false`.
    open func moduleCanStart(with context: RAContext?) -> Bool { true }
    
    /// Called when the module is about to be started.
    ///
    /// This method is called before the view of this module appears.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func moduleWillStart() -> Void {}
    
    /// Called when the module has become active.
    ///
    /// This method is called afted the view of this module appeared.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func moduleDidStart() -> Void {}
    
    /// Called when the module is about to be stopped.
    ///
    /// This method is called before the view of this module disappears.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func moduleWillStop() -> Void {}
    
    /// Called when the module has become inactive.
    ///
    /// This method is called afted the view of this module disappeared.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func moduleDidStop() -> Void {}
    
    /// Called when the module is about to be unloaded from parent memory.
    ///
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func moduleWillUnload() -> Void {}
    
    
    // MARK: - Lifecycle
    
    /// Setups this interactor before it starts working.
    ///
    /// This method is called when the module into which this interactor integrated is assembled and loaded into the module tree.
    /// You usually override this method to perform additional initialization on your private properties.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func setup() -> Void {}
    
    /// Cleans this interactor after it stops working.
    ///
    /// This method is called when the module into which this interactor integrated is about to be unloaded from the module tree and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func clean() -> Void {}
    
    
    // MARK: - Init and Deinit
    
    /// Creates an interactor instance.
    fileprivate init() {
        RALeakDetector.register(self)
    }
    
    deinit {
//        RALeakDetector.release(self)
    }
    
}
