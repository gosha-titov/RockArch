import Foundation

/// The information about a file this instance originates from.
///
/// For example, you create the `RAFileInfo` instance inside the `TestProject/ViewControllers/ViewController.swift` file:
///
///     final class ViewController: UIViewController {
///
///         override func viewDidLoad() {
///             super.viewDidLoad()
///
///             let file = RAFileInfo()
///             file.id     // "TestProject/ViewController.swift"
///             file.module // "TestProject"
///             file.name   // "ViewController"
///
///             print(file)
///             // Prints "TestProject/ViewController.swift"
///         }
///
///     }
///
/// The file info is mainly used in log messages.
public struct RAFileInfo: CustomStringConvertible {
    
    /// The name of the module and file. It's the same as `#fileID`.
    public let id: String
    
    /// The name of a module this file originates from.
    public let module: String
    
    /// The name of a file.
    public let name: String
    
    /// A textual representation of this file information.
    ///
    /// Returns a value of the `id` property.
    public var description: String { id }
    
    /// Creates an instance of the file information.
    /// - Parameter fileID: Pass value of the `fileID` literal.
    public init(fileID: String = #fileID) {
        
        id = fileID
        
        // Extract module name from fileID
        if let slashIndex = fileID.firstIndex(of: "/") {
            module = String(fileID[..<slashIndex])
        } else { module = "" }
        
        // Extract file name from fileID
        name = URL(fileURLWithPath: fileID).deletingPathExtension().lastPathComponent
    }
    
}
