import UIKit // to launch from the window

// Implementation notes
// ====================
//
// The module uses a data structure like this:
//
//  ┌────────────────┐          ┌─────────────────┐
//  │[class RAModule]├─────────▶│[class RABuilder]│
//  │                │◀─ ─ ─ ─ ─┤                 │
//  │ interactor     │          │ _module         │
//  │ router         │          └─────────────────┘
//  │ view           │
//  │ builder        │
//  └──┬─────┬─────┬─┘
//   ▲ │   ▲ │   ▲ │
//   ╎ │   ╎ │   ╎ └───────────────────────────────────────────────┐
//   ╎ │   ╎ │   └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │
//   ╎ │   ╎ │                                                   ╎ │
//   ╎ │   ╎ └─────────────────────┐                             ╎ │
//   ╎ │   └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │                             ╎ │
//   ╎ ▼                         ╎ ▼                             ╎ ▼
//  ┌┴───────────────┐          ┌┴───────────────────┐          ┌┴─────────────┐
//  │[class RARouter]│          │[class RAInteractor]├─ ─ ─ ─ ─▶│[class RAView]│
//  │                │◀─ ─ ─ ─ ─┤                    │◀─ ─ ─ ─ ─┤              │
//  │ _module        │          │ _module            │          │ _module      │
//  │ viewController │          │ _router            │          │ _interactor  │
//  └──────┬─────────┘          │ _view              │          └──────────────┘
//         ╎                    └────────────────────┘                 ▲
//         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
//
//
// Lifecycle methods
// -----------------
//
// Below is a method chaining that includes main lifecycle methods of each component:
//
//   │ Module  │ Interactor  │ Router  │ View  │ Builder │
//   ├─────────┼─────────────┼─────────┼───────┼─────────┤
//     assemble()
//     setup()
//   ├ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ─ ┤
//     canLoad()
//                             setupContainerController()
//                             loadEmbeddedViewControllers()
//                                       loadEmbeddedViewControllers()
//   ├ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ─ ┤
//     load()
//               setup()
//                             setup()
//                                       setup()
//                                               setup()
//               moduleDidLoad()
//   ├ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ─ ┤
//               moduleWillStart()
//     start()
//                                       viewDidLoad()
//                                       viewWillAppear()
//                                       viewDidAppear()
//               moduleDidStart()
//   ├ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ─ ┤
//               moduleWillStop()
//                                       viewWillDisappear()
//                                       viewDidDisappear()
//     stop()
//     result()
//               result()
//               moduleDidStop()
//   ├ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ─ ┤
//               moduleWillUnload()
//     unload()
//     clean()
//               clean()
//                             clean()
//                                       clean()
//                                               clean()
//     disassemble()
//   └─────────┴─────────────┴─────────┴───────┴─────────┘

/// A module that is responsible for dividing the application into independent parts.
///
/// The `RAModule` class defines the shared behavior that’s common to all modules.
/// You almost always subclass the `RAModule` but you make minor changes,
/// since each module has already defined all behavior methods: organizing the module hierarchy (the module tree),
/// establishing the relationship between modules, coordinating with them and so on.
///
/// The module consists of 4 components:
/// - **Interactor** that is responsible for all business logic of this module;
/// - **Router**  that is responsible for the hierarchy of modules: showing and hiding child modules, completing this module;
/// - **View** that is responsible for configurating and updating UI, catching and handling user interactions;
/// - **Builder** that is responsible for creating child modules by their associated names.
///
/// The module has an internal lifecycle consisting of loading, starting, stopping and unloading methods.
/// In order to manage it, use the `lifecycleDelegate` property that is notified in case of changes.
///
/// The module also has two additional lifecycle methods: `setup()` and `clean()`,
/// which are called when the module is attached to or detached from the module tree.
/// You can override these to perform additional initialization on your properties and, accordingly, to clean them.
///
/// To be able to provide data to children and handle it from them, you use the `dataProvider` and `dataHandler` properties.
/// Usually these three (including `lifecycleDelegate`) are the same object.
/// By default, it's the interactor of this module, but you can change it by setting your values for them.
///
/// For starting the module tree, you call the `launch(from:)` method that will make this module the root.
///
/// For example, the main module may look like this:
///
///     final class MainModule: RAModule {
///
///         static let name = "Main"
///
///         override func setup() -> Void {
///             embedChildModule(byName: FeedModule.name)
///             embedChildModule(byName: MessagesModule.name)
///             embedChildModule(byName: SettingsModule.name)
///             isDependentOnEmbeddedModules = true
///             isUnloadedIfCompleted = false
///         }
///
///         init() {
///             super.init(
///                 name:       MainModule.name,
///                 interactor: MainInteractor(),
///                 router:     MainRouter(),
///                 view:       MainView(),
///                 builder:    MainBuilder()
///             )
///         }
///
///     }
///
/// - Note: Each component can log messages by calling the `log(_:category:level:)` method.
/// These messages are handled by the current black box with its loggers.
///
open class RAModule: RAModuleInterface {
    
    // MARK: General Info
    
    /// A string associated with the name of this module.
    ///
    /// You usually name modules like: `Main`, `Feed`, `Chats`, `Settings`, `Profile`, `Appearance` and so on.
    /// It's mainly used to build and start modules, to communicate and interact with other modules, to log messages.
    /// - Note: Names are an important part of the architecture.
    /// In order to avoid ambiguities,  **name modules uniquely**.
    public let name: String
    
    /// A textual representation of the type of this object.
    ///
    /// This property has the "Module" value.
    public let type: String = "Module"
    
    /// The current state of this module.
    ///
    /// The state represents whether the module is currently running or not.
    /// The default value is `.inactive`.
    public private(set) var state: RAComponentState = .inactive
    
    /// A string containing the full path to this module.
    ///
    /// For example, the path to the `Themes` module may look like this:
    ///
    ///     module.path // "Main/Settings/Appearance/Themes"
    ///
    public final var path: String {
        if let parent { return parent.path + "/" + name }
        else { return name }
    }
    
    /// A boolean value that indicates whether this module is the root for the module tree.
    public private(set) var isRoot: Bool = false
    
    /// A boolean value that indicates whether this module is loaded into the module tree.
    public private(set) var isLoaded: Bool = false
    
    /// A boolean value that indicates whether the module behavior depends on its embedded child modules.
    ///
    /// If behavior depends on embedded child modules and one of them cannot be loaded or started,
    /// then this module cannot be loaded or started too.
    ///
    /// The default value is `false`.
    public var isDependentOnEmbeddedModules = false
    
    /// A boolean value that indicates whether this module is unloaded after completing its work.
    ///
    /// If this flag is `false` then the parent module keeps this module loaded
    /// after this module completes its work (becomes inactive).
    ///
    /// The default value is `true`.
    public var isUnloadedIfCompleted = true
    
    
    // MARK: Relatives
    
    /// The root module of the application.
    ///
    /// The module tree grows (begins) with the root module.
    /// In order for some module to become root, you call the `launch(from:)` method.
    public private(set) static var root: RAModule? = nil
    
    /// An array containing all modules of the module tree.
    public static var all: [RAModule] {
        return root?.all ?? []
    }
    
    /// An array containing this module and its children (and children of these children, and so on).
    public final var all: [RAModule] {
        return [self] + children.flatMap { $0.value.all }
    }
    
    /// A parent module that owns this module, or `nil`.
    public internal(set) weak var parent: RAModule?
    
    /// The dictionary that stores created and loaded child modules by their names.
    public private(set) var children = [String: RAModule]()
    
    /// The child modules that are active.
    private var activeChildren: [String: RAModule] {
        return children.filter { $0.value.isActive }
    }
    
    /// The child modules that are embedded in this module.
    public final var embeddedChildren: [String: RAModule] {
        return children.filter { namesOfEmbeddedChildren.contains($0.key) }
    }
    
    /// The names of the child modules embedded in this module.
    public private(set) var namesOfEmbeddedChildren = [String]()
    
    /// The names of the child modules that should be embedded during the loading of this module.
    ///
    /// These names are specified by a developer in the `setup()` method by using the `embedChildModule(byName:)` method.
    /// Then corresponding child modules are built and loaded during the loading process of this module  (that is, they becomes embedded).
    private var namesOfChildrenThatShouldBeEmbedded = [String]()
    
    
    // MARK: Inner Components
    
    /// The internal interactor of this module.
    internal let interactor: RAAnyInteractor
    
    /// The internal router of this module.
    internal let router: RARouter
    
    /// The internal view of this module.
    internal let view: (any RAView)
    
    /// The internal builder of this module, or `nil`.
    internal let builder: RABuilder?
    
    
    // MARK: Delegates
    
    /// The object that acts as the lifecycle delegate of this module.
    public var lifecycleDelegate: RAModuleLifecycleDelegate
    
    /// The object that provides the data for specific modules.
    public var dataProvider: RAModuleDataProvider
    
    /// The object that handles the data from specific modules.
    public var dataHandler: RAModuleDataHandler
    
    
    // MARK: - Launching
    
    /// Launches the module tree from the given window, making this module the root.
    ///
    /// Firstly, you define a new initialization to simplify the creation, as in the following example:
    ///
    ///     final class MainModule: RAModule {
    ///
    ///         static let name = "Main"
    ///
    ///         override init() {
    ///             super.init(
    ///                 name:       MainModule.name,
    ///                 interactor: MainInteractor(),
    ///                 router:     MainRouter(),
    ///                 view:       MainView(),
    ///                 builder:    MainBuilder()
    ///             )
    ///         }
    ///
    ///     }
    ///
    /// Then you create the module and launch it by calling the `launch(from:)` method from the `SceneDelegate` class:
    ///
    ///     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    ///
    ///         guard let windowScene = (scene as? UIWindowScene) else { return }
    ///         let window = UIWindow(windowScene: windowScene)
    ///         self.window = window
    ///
    ///         let mainModule = MainModule()
    ///         mainModule.launch(from: window)
    ///     }
    ///
    /// - Parameter window: The window whose the `rootViewController` property will be used to display the view controllers of the module tree.
    /// - Returns: `True` if this module has become the root; otherwise, `false`.
    @discardableResult
    public final func launch(from window: UIWindow) -> Bool {
        guard canLoad() else {
            log("Couldn't be launched from the window because this module couldn't be loaded",
                category: .moduleLifecycle, level: .error)
            return false
        }
        if let root = RAModule.root, root.isActive {
            root.willStop()
            root.stop()
            root.didStop()
            root.willUnload()
            root.unload()
        }
        window.rootViewController = view
        window.makeKeyAndVisible()
        RAModule.root = self
        isRoot = true
        load()
        didLoad()
        guard canStart(with: nil) else {
            log("Couldn't be launched from the window because this module couldn't be started",
                category: .moduleLifecycle, level: .error)
            return false
        }
        willStart()
        start()
        didStart()
        return true
    }
    
    
    // MARK: - Interactions between Modules
    
    /// Returns an interactor of a specific related module.
    internal final func interactor(of relative: RARelative) -> RAAnyInteractor? {
        switch relative {
        case .child(let childName): return children[childName]?.interactor
        case .parent: return parent?.interactor
        }
    }
    
    /// Returns a router of a specific related module.
    internal final func router(of relative: RARelative) -> RARouter? {
        switch relative {
        case .child(let childName): return children[childName]?.router
        case .parent: return parent?.router
        }
    }
    
    
    // MARK: - Communication between Modules
    
    /// Sends the given signal to a specific receiver.
    /// - Returns: `True` if the receiver (or at least one of them) has handled this signal; otherwise, `false`.
    public final func send(_ signal: RASignal, to receiver: RAReceiver) -> Bool {
        var signalIsSended: Bool = false
        func sendSignal(to module: RAModule, from sender: RASender) -> Void {
            if module.handle(signal, from: sender) {
                signalIsSended = true
            }
        }
        switch receiver {
        case .global(let globalReceiver):
            let allModules = RAModule.all
            let sender: RASender = .global(name)
            switch globalReceiver {
            case .all:
                allModules.forEach { sendSignal(to: $0, from: sender) }
            case .group(let globalNames):
                allModules.filter { globalNames.contains($0.name) }
                    .forEach { sendSignal(to: $0, from: sender) }
            case .some(let globalName):
                allModules.filter { $0.name == globalName }
                    .forEach { sendSignal(to: $0, from: sender) }
            }
        case .parent:
            guard let parent else {
                log("Couldn't send the `\(signal)` to the nonexistent parent",
                    category: .moduleCommunication, level: .error)
                return false
            }
            let sender: RASender = .child(name)
            sendSignal(to: parent, from: sender)
        case .child(let childReceiver):
            let children = children.values
            let sender: RASender = .parent(name)
            switch childReceiver {
            case .all:
                children.forEach { sendSignal(to: $0, from: sender) }
            case .group(let childrenNames):
                children.filter { childrenNames.contains($0.name) }
                    .forEach { sendSignal(to: $0, from: sender) }
            case .some(let childName):
                guard let child = children.first(where: { $0.name == childName }) else {
                    log("Couldn't send the `\(signal)` to the `\(childName)` nonexistent child",
                        category: .moduleCommunication, level: .error)
                    return false
                }
                sendSignal(to: child, from: sender)
            }
        }
        return signalIsSended
    }
    
    /// Handles the given signal from a specifc sender.
    /// - Returns: `True` if the signal has been handled; otherwise, `false`.
    @discardableResult
    internal final func handle(_ signal: RASignal, from sender: RASender) -> Bool {
        switch sender {
        case .global(let globalName):
            guard RAModule.all.contains(where: { $0.name == globalName }) else {
                log("Couldn't handle the `\(signal)` signal from the `\(globalName)` unknown global module",
                    category: .moduleCommunication, level: .error)
                return false
            }
            dataHandler.global(globalName, didPass: signal.value, with: signal.label)
        case .parent(let parentName):
            guard let parent, parent.name == parentName else {
                log("Couldn't handle the `\(signal)` signal from the `\(parentName)` unknown parent module",
                    category: .moduleCommunication, level: .error)
                return false
            }
            dataHandler.parent(parentName, didPass: signal.value, with: signal.label)
        case .child(let childName):
            guard children.hasKey(childName) else {
                log("Couldn't handle the `\(signal)` signal from the `\(childName)` unknown child module",
                    category: .moduleCommunication, level: .error)
                return false
            }
            dataHandler.child(childName, didPass: signal.value, with: signal.label)
        }
        return true
    }
    
    /// Handles a work result from the given child module.
    private func handleResult(from child: RAModule) -> Void {
        guard child.isInactive else { return }
        let childResult = child.result()
        dataHandler.child(child.name, didCompleteWith: childResult)
    }
    
    /// Returns the work result of this module.
    internal final func result() -> RAResult? {
        for child in children.values {
            handleResult(from: child)
        }
        let result = dataProvider.result()
        return result
    }
    
    /// Provides a context to the given child module.
    /// - Returns: `True` if this child module can be started; otherwise, `false`.
    private func provideContext(to child: RAModule) -> Bool {
        guard child.isInactive else {
            log("Couldn't provide a context to the `\(child.name)` child module because it was already started",
                category: .moduleManagement, level: .error)
            return false
        }
        let context = dataProvider.context(forChildModuleWithName: child.name)
        return child.canStart(with: context)
    }
    
    
    // MARK: - Invoking and Revoking
    
    /// Invokes a specific child module by its associated name.
    ///
    /// The invoking process represents the building, loading and starting a specific child module,
    /// or starting a child module that was already preloaded.
    internal final func invokeChild(byName childName: String, animation show: RADefaultAnimation) -> Bool {
        guard isLoaded else {
            log("Couldn't invoke the `\(childName)` child module because this module wasn't loaded",
                category: .moduleManagement, level: .error)
            return false
        }
        guard isActive else {
            log("Couldn't invoke the `\(childName)` child module because this module wasn't active",
                category: .moduleManagement, level: .error)
            return false
        }
        let child: RAModule
        if let existingChild = children[childName] {
            guard existingChild.isInactive else { return false }
            child = existingChild
        } else {
            guard let newChild = buildChild(byName: childName) else {
                log("Couldn't invoke the `\(childName)` child module because it couldn't be built",
                    category: .moduleManagement, level: .error)
                return false
            }
            guard load(newChild) else {
                log("Couldn't invoke the `\(childName)` child module because it couldn't be loaded",
                    category: .moduleManagement, level: .error)
                return false
            }
            child = newChild
        }
        return start(child, animation: show)
    }
    
    /// Revokes a specific child module by its associated name.
    ///
    /// The invoking process represents the stopping (and sometimes unloading) child module.
    internal final func revokeChild(byName childName: String, animation hide: RADefaultAnimation) -> Bool {
        guard isLoaded else {
            log("Couldn't revoke the `\(childName)` child module because this module wasn't loaded",
                category: .moduleManagement, level: .error)
            return false
        }
        guard isActive else {
            log("Couldn't revoke the `\(childName)` child module because this module wasn't active",
                category: .moduleManagement, level: .error)
            return false
        }
        guard let child = children[childName] else {
            log("Couldn't revoke the `\(childName)` unknown child module",
                category: .moduleManagement, level: .error)
            return false
        }
        guard child.isActive else { return true }
        return stop(child, animation: hide) && (child.isUnloadedIfCompleted ? unload(child) : true)
    }
    
    
    // MARK: - Starting and Stoping Modules
    
    /// Starts the given child module.
    ///
    /// The starting process includes providing a context to the given child.
    /// - Returns: `True` if the child module has been started; otherwise, `false`.
    @discardableResult
    private func start(_ child: RAModule, animation show: RADefaultAnimation) -> Bool {
        guard isLoaded else {
            log("Couldn't start the `\(child.name)` child module because this module wasn't loaded",
                category: .moduleManagement, level: .error)
            return false
        }
        guard isActive else {
            log("Couldn't start the `\(child.name)` child module because this module wasn't active",
                category: .moduleManagement, level: .error)
            return false
        }
        let childExists = children.hasKey(child.name)
        guard childExists else {
            log("Couldn't start the `\(child.name)` unknown child module",
                category: .moduleManagement, level: .error)
            return false
        }
        guard child.isInactive else {
            log("Couldn't start the `\(child.name)` child module because it was already started",
                category: .moduleManagement, level: .warning)
            return false
        }
        let childCanStart = provideContext(to: child)
        guard childCanStart else {
            log("Couldn't start the `\(child.name)` child module",
                category: .moduleManagement, level: .error)
            return false
        }
        child.willStart()
        child.start()
        show(child.view)
        child.didStart()
        return true
    }
    
    /// Stops the given child module.
    ///
    /// The stopping process includes handling a work result of the given child module.
    /// - Returns: `True` if the child module has been stopped; otherwise, `false`.
    @discardableResult
    private func stop(_ child: RAModule, animation hide: RADefaultAnimation) -> Bool {
        guard isLoaded else {
            log("Couldn't stop the `\(child.name)` child module because this module wasn't loaded",
                category: .moduleManagement, level: .error)
            return false
        }
        guard isActive else {
            log("Couldn't stop the `\(child.name)` child module because this module wasn't active",
                category: .moduleManagement, level: .error)
            return false
        }
        let childExists = children.hasKey(child.name)
        guard childExists else {
            log("Couldn't stop the `\(child.name)` unknown child module",
                category: .moduleManagement, level: .error)
            return false
        }
        guard child.isActive else {
            log("Couldn't stop the `\(child.name)` child module because it was inactive",
                category: .moduleManagement,
                level: .warning)
            return false
        }
        child.willStop()
        hide(child.view)
        child.stop()
        handleResult(from: child)
        child.didStop()
        return true
    }
    
    
    // MARK: - Loading Modules
    
    /// Loads a specific child module into memory by its associated name.
    ///
    /// The loading process represents the building of the child module, attaching it to the module tree by adding it to children of this module and configuring it.
    /// - Returns: `True` if the given module was loaded successfully; otherwise, `false`.
    public final func loadChild(byName childName: String) -> Bool {
        guard isLoaded else {
            log("Couldn't load the `\(childName)` child module because this module wasn't loaded into memory",
                category: .moduleManagement, level: .error)
            return false
        }
        let childDoesNotExist = !children.hasKey(childName)
        guard childDoesNotExist else { return true }
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
    public final func unloadChild(byName childName: String) -> Bool {
        guard let child = children[childName] else { return true }
        guard child.isInactive else {
            log("Couldn't unload the `\(childName)` child module because it's active",
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
        let childDoesNotExist = !children.hasKey(child.name)
        guard childDoesNotExist else { return true }
        guard child.canLoad() else {
            log("Couldn't load the `\(child.name)` child module",
                category: .moduleManagement, level: .error)
            return false
        }
        attach(child)
        child.load()
        child.didLoad()
        return true
    }
    
    /// Unloads the given module from memory by detaching it from the module tree.
    ///
    /// The unloading process represents the detaching the given module from the module tree by removing it from children of this module and deconfiguring it.
    /// - Parameter child: The module that will no longer be a child of this module during the unloading process.
    /// - Returns: `True` if the given module was unloaded successfully; otherwise, `false`.
    private func unload(_ child: RAModule) -> Bool {
        let childExists = children.contains(value: child)
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
    
    /// Returns a child module created by the specified name.
    private func buildChild(byName childName: String) -> RAModule? {
        guard let builder else {
            log("Couldn't build the `\(childName)` child module because this module didn't have a builder",
                category: .moduleManagement, level: .error)
            return nil
        }
        let dependency = dataProvider.dependency(forChildModuleWithName: childName)
        return builder.buildChildModule(byName: childName, with: dependency)
    }
    
    
    // MARK: - Embedding
    
    /// Embeds a specific module into this module by its associated name.
    ///
    /// It's used for a composite module. For example, for a tab bar module:
    ///
    ///     override func setup() -> Void {
    ///         embedChildModule(byName: FeedModule.name)
    ///         embedChildModule(byName: MessagesModule.name)
    ///         embedChildModule(byName: SettingsModule.name)
    ///     }
    ///
    /// - Note: The embedded child module becomes built and loaded only during the loading of this module.
    /// That is, this method should be called in the `setup()` method.
    /// - Returns: `True` if the child added to embedded modules; otherwise, `false`.
    @discardableResult
    public final func embedChildModule(byName childName: String) -> Bool {
        guard isLoaded == false else {
            log("Couldn't embed the `\(childName)` child module because this module was loaded",
                category: .moduleManagement, level: .error)
            return false
        }
        guard namesOfChildrenThatShouldBeEmbedded.contains(childName) == false else {
            log("Couldn't embed the `\(childName)` child module twice",
                category: .moduleManagement, level: .warning)
            return false
        }
        namesOfChildrenThatShouldBeEmbedded.append(childName)
        return true
    }
    
    /// Embedes the given modules by attaching it to the module tree.
    private func embed(builtModules: [String: RAModule]) -> Void {
        builtModules.values.forEach { attach($0) }
        namesOfEmbeddedChildren = builtModules.keys.asArray
    }
    
    
    // MARK: - Lifecycle
    
    // MARK: Loading
    
    /// Asks this module if it can be loaded.
    ///
    /// - Note: If the module behavior depends on its embedded child modules and one of these modules cannot be built or loaded,
    /// then this module cannot be loaded too.
    /// - Returns: `True` if module can be loaded; otherwise, `false`.
    internal final func canLoad() -> Bool {
        var builtChildren = [String: RAModule]()
        for childName in namesOfChildrenThatShouldBeEmbedded {
            if let builtChild = buildChild(byName: childName) {
                builtChildren[childName] = builtChild
            } else {
                guard isDependentOnEmbeddedModules == false else {
                    log("Couldn't be loaded because the `\(childName)` embedded module wasn't built",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
            }
        }
        for child in builtChildren.values {
            if child.canLoad() == false {
                guard isDependentOnEmbeddedModules == false else {
                    log("Couldn't be loaded because one of the embedded modules wasn't loaded",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
                builtChildren.removeValue(forKey: child.name)
            }
        }
        embed(builtModules: builtChildren)
        guard router.setupContainerController() else {
            log("Couldn't be loaded because the router didn't setup a contrainer controller",
                category: .moduleLifecycle, level: .error)
            return false
        }
        guard router.loadEmbeddedViewControllers() else {
            log("Couldn't be loaded because the router didn't load embedded child view controllers",
                category: .moduleLifecycle, level: .error)
            return false
        }
        guard view.loadEmbeddedViewControllers() else {
            log("Couldn't be loaded because the view didn't load embedded children",
                category: .moduleLifecycle, level: .error)
            return false
        }
        return true
    }
    
    /// Loads this module and its embedded child modules.
    ///
    /// Called when this module is in the process of being added to the module tree by the parent module.
    internal final func load() -> Void {
        embeddedChildren.values.forEach { $0.load() }
        isLoaded = true
        interactor.setup()
        router.setup()
        view.setup()
        builder?.setup()
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
    internal final func canStart(with context: RAContext?) -> Bool {
        for child in embeddedChildren.values {
            let childCanStart = provideContext(to: child)
            if childCanStart == false {
                guard isDependentOnEmbeddedModules == false else {
                    log("Couldn't be started because the `\(child.name)` embedded child module couldn't be started",
                        category: .moduleLifecycle, level: .error)
                    return false
                }
            }
        }
        let thisModuleCanStart = lifecycleDelegate.moduleCanStart(with: context)
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
    
    
    // MARK: Stopping
    
    /// Notifies this module and its embedded children that they are about to be stopped.
    internal final func willStop() -> Void {
        activeChildren.values.forEach { $0.willStop() }
        lifecycleDelegate.moduleWillStop()
    }
    
    /// Called when this module should stop its work for some reason.
    internal final func stop() -> Void {
        activeChildren.values.forEach { $0.stop() }
        state = .inactive
        log("Stopped working", category: .moduleLifecycle)
    }
    
    /// Notifies this module and its embedded children that they are stopped.
    internal final func didStop() -> Void {
        activeChildren.values.forEach { $0.didStop() }
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
        deconfigure()
        isLoaded = false
        state = .inactive
        log("Unloaded from memory", category: .moduleLifecycle)
    }
    
    
    // MARK: - Assembly and Disassembly
    
    /// Assembles this module by connecting its inner components to each other and to this module.
    private func assemble() -> Void {
        router.viewController = view
        view._interactor = interactor
        interactor._router = router
        interactor._view = view
        interactor._module = self
        router._module = self
        view._module = self
        builder?._module = self
    }
    
    /// Disassembles this module by disconnecting components from each other and from this module.
    private func disassemble() -> Void {
        router.viewController = nil
        view._interactor = nil
        interactor._router = nil
        interactor._view = nil
        interactor._module = nil
        router._module = nil
        view._module = nil
        builder?._module = nil
    }
    
    
    // MARK: Setuping and Cleaning
    
    /// Setups this module before it starts working.
    ///
    /// This method is called when this module is assembled but not yet loaded into the module tree.
    /// You usually override this method to perform additional initialization on your properties.
    ///
    /// Most ofter you use this method in the following way:
    ///
    ///     overrive func setup() -> Void {
    ///         embedChildModule(byName: FeedModule.name)
    ///         embedChildModule(byName: MessagesModule.name)
    ///         embedChildModule(byName: SettingsModule.name)
    ///         isDependentOnEmbeddedModules = true
    ///         isUnloadedIfCompleted = false
    ///         loadChildModule(byName: OrdersModule.name)
    ///     }
    ///
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func setup() -> Void {}
    
    /// Cleans this module after it stops working.
    ///
    /// This method is called when this module is about to be unloaded from memory and disassembled.
    /// You usually override this method to clean your properties.
    /// You don't need to call the `super` method, because the default implementation does nothing.
    open func clean() -> Void {}
    
    /// Performs internal setup for this module before it starts working by calling setup methods of this module and its inner components.
    private func configure() -> Void {
        assemble()
        setup()
    }
    
    /// Performs internal clean for this module after it stops working by calling the setup method of this module and its inner components.
    private func deconfigure() -> Void {
        clean()
        interactor.clean()
        router.clean()
        view.clean()
        builder?.clean()
        disassemble()
        children.removeAll()
        namesOfEmbeddedChildren.removeAll()
        namesOfChildrenThatShouldBeEmbedded.removeAll()
    }
    
    
    // MARK: - Init and Deinit
    
    /// Creates a named module instance with the given components.
    ///
    /// - Parameter name: A string that will be associated with this module.
    /// The inner components (interactor, router, view, builder) of this module will also have this name.
    /// It will be displayed in logs, paths, links, etc.
    ///
    /// - Parameter interactor: The interactor that is responsible for all business logic of this module.
    /// It's also a built-in delegate of the module lifecycle, data handling and providing, and It can interact with other related interactors.
    /// Implement this by subclassing the `RAInteractor` class.
    ///
    /// - Parameter router: The router that is responsible for the hierarchy of modules.
    /// It can show and hide child modules, and it can complete this module.
    /// Implement this by subclassing the `RARouter` class.
    ///
    /// - Parameter view: The view that is responsible for configurating and updating UI, catching and handling user interactions.
    /// Implement this by creating a new class that conforms to the `RAView` protocol.
    ///
    /// - Parameter builder: The builder that is responsible for creating child modules by their associated names.
    /// Implement this by subclassing the `RABuilder` class.
    /// If this module doesn't have child modules, then pass `nil` (default).
    ///
    public init(name: String, interactor: RAAnyInteractor, router: RARouter, view: any RAView, builder: RABuilder? = nil) {
        self.name = name
        self.interactor = interactor
        self.router = router
        self.view = view
        self.builder = builder
        lifecycleDelegate = interactor
        dataHandler = interactor
        dataProvider = interactor
        log("Created", category: .moduleLifecycle)
        RALeakDetector.register(self)
        RALeakDetector.register(view) // It can't register by itself
        configure()
    }
    
    deinit {
//        RALeakDetector.release(self)
        log("Deleted", category: .moduleLifecycle)
    }
    
}



/// A communication interface from a component to its module into which it is integrated.
public protocol RAModuleInterface: RAComponent {
    
    /// A boolean value that indicates whether this module is loaded into the module tree.
    var isLoaded: Bool { get }
    
    /// A string containing the full path to this module.
    var path: String { get }
    
}


// MARK: - Delegates

/// The methods adopted by the object you use to provide data for specific modules.
public protocol RAModuleDataProvider where Self: RAAnyObject {
    
    /// Provides a dependency for a specific child module when it loads into memory.
    func dependency(forChildModuleWithName childName: String) -> RADependency?
    
    /// Provides a context for a specific child module when it starts.
    func context(forChildModuleWithName childName: String) -> RAContext?
    
    /// Provides the work result of the module.
    func result() -> RAResult?
    
}


/// The methods adopted by the object you use to handle data from specific modules.
public protocol RAModuleDataHandler where Self: RAAnyObject {
    
    /// Handles the incoming value from a specific module from the entire module tree.
    func global(_ moduleName: String, didPass value: Any, with label: String) -> Void
    
    /// Handles the incoming value from a parent module.
    func parent(_ parentName: String, didPass value: Any, with label: String) -> Void
    
    /// Handles the incoming value from a specific child module.
    func child(_ childName: String, didPass value: Any, with label: String) -> Void
    
    /// Handles the work result of a specific child module.
    func child(_ childName: String, didCompleteWith result: RAResult?) -> Void
    
}


/// The methods adopted by the object you use to manage the lifecycle of a specific module.
public protocol RAModuleLifecycleDelegate where Self: RAAnyObject {
    
    /// Notifies the delegate that the module is loaded into the parent memory.
    func moduleDidLoad() -> Void
    
    /// Asks the delegate what context is required in order for the module to be started.
    func moduleCanStart(with context: RAContext?) -> Bool
    
    /// Notifies the delegate that the module is about to be started.
    func moduleWillStart() -> Void
    
    /// Notifies the delegate that the module is started.
    func moduleDidStart() -> Void
    
    /// Notifies the delegate that the module is about to be stopped.
    func moduleWillStop() -> Void
    
    /// Notifies the delegate that the module is stopped.
    func moduleDidStop() -> Void
    
    /// Notifies the delegate that the module is about to be unloaded from the parent memory.
    func moduleWillUnload() -> Void
    
}



// MARK: - Sender and Receiver

/// A receiver of a signal.
///
/// It's used when modules communicate with each other.
public enum RAReceiver {
    
    /// A global receiver among the entire module tree.
    ///
    /// It can be either one or several, or all of modules in the module tree.
    public enum Global {
        
        /// All modules in the entire module tree.
        case all
        
        /// A specific group of modules in the entire module tree.
        case group([String])
        
        /// A specific module in the entire module tree.
        /// - Note: If several same modules are running among the module tree,
        /// so each of them is considered.
        case some(String)
        
    }
    
    /// A child receiver among the child modules.
    ///
    /// It can be either one or several, or all of child modules.
    public enum Child {
        
        /// All child modules of this module.
        case all
        
        /// A specific group of child modules of this module.
        case group([String])
        
        /// A specific child module of this module.
        case some(String)
        
    }
    
    /// A receiver that is among the entire module tree.
    case global(Global)
    
    /// A receiver that is the parent module of this module.
    case parent
    
    /// A receiver that is among child modules.
    case child(Child)
    
}


/// A sender of a signal.
///
/// It's used when modules communicate with each other.
public enum RASender {
    
    /// A sender that is a module from the entire module tree.
    case global(String)
    
    /// A sender that is the parent module of this module.
    case parent(String)
    
    /// A sender that is the child module of this module.
    case child(String)
    
}



/// A relative that specifies a relationship between two objects
///
/// For example, the **A** module loads the **B** module into its memory.
/// That is, **A** becomes a **parent** for **B**, and **B** becomes a **child** for **A**.
///
/// It's used to avoid overloading methods.
internal enum RARelative: Equatable {
    
    /// A child of this module.
    case child(String)
    
    /// A parent of this module.
    case parent
    
}
