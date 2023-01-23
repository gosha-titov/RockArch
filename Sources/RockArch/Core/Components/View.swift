import UIKit

public protocol RAView: RAComponentIntegratedIntoModule where Self: UIViewController {
    
    associatedtype InteractorInterface
    
    var interactor: InteractorInterface? { get }
    
}

public extension RAView {
    
    var module: RAModule? {
        get {
            let storage = RAWeakModuleStorage.shared
            return storage.object(byKey: debugDescription)
        }
        set {
            let storage = RAWeakModuleStorage.shared
            if let module = newValue {
                storage.register(module, forKey: debugDescription)
            } else {
                storage.removeObject(forKey: debugDescription)
            }
        }
    }
    
    var interactor: InteractorInterface? {
        return _interactor as? InteractorInterface
    }
    
    var type: String {
        return "View"
    }
    
    func setup() {}
    
    func clean() {}
    
}


extension UIViewController {
    
    /// An internal interactor that is set by a module.
    internal var _interactor: RAAbstractInteractor? {
        get {
            let storage = RAWeakInteractorStorage.shared
            return storage.object(byKey: debugDescription)
        }
        set {
            let storage = RAWeakInteractorStorage.shared
            if let interactor = newValue {
                storage.register(interactor, forKey: debugDescription)
            } else {
                storage.removeObject(forKey: debugDescription)
            }
        }
    }
    
    /// Called when the module is loaded into memory and assembled.
    internal func _setup() -> Void {
        guard let self = self as? RAComponentIntegratedIntoModule else { return }
        RALeakDetector.register(self)
        self.setup()
    }
    
    /// Called when the module is about to be unloaded from memory and disassembled.
    internal func _clean() -> Void {
        guard let self = self as? RAComponentIntegratedIntoModule else { return }
        self.clean()
    }
    
}
