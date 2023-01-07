import Foundation

/// The information about a file, function and line in which this instance is created.
///
/// For example, you create an information inside `TestProject/ViewControllers/ViewController.swift`:
///
///     final class ViewController: UIViewController {
///
///         override func viewDidLoad() {
///             super.viewDidLoad()
///
///             let info = RAInfo()
///             info.file.id     // "TestProject/ViewController.swift"
///             info.file.module // "TestProject"
///             info.file.name   // "ViewController"
///             info.function    // "viewDidLoad()"
///             info.line        // 8
///         }
///
///     }
///
public struct RAInfo {
    
    /// The information about the file.
    let file: RAFileInfo
    
    /// The name of the function.
    let function: String
    
    /// The number of the line.
    let line: Int
    
    /// Creates an instance of the source information.
    /// - Parameter fileID:   Pass value of the `#fileID` literal.
    /// - Parameter function: Pass value of the `#function` literal.
    /// - Parameter line:     Pass value of the `#line` literal.
    public init(fileID: String = #fileID, function: String = #function, line: Int = #line) {
        self.file = RAFileInfo(fileID: fileID)
        self.function = function
        self.line = line
    }
    
}


/// The information about a file in which this instance is created.
///
/// For example, you create a file information inside the `TestProject/ViewControllers/ViewController.swift` file:
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
///         }
///
///     }
///
public struct RAFileInfo: CustomStringConvertible {
    
    /// The name of the module and file. It's the same as `#fileID`.
    public let id: String
    
    /// Returns the module in which the file is located.
    public var module: String {
        if let slashIndex = id.firstIndex(of: "/") {
            let startIndex = id.startIndex
            return String(id[startIndex..<slashIndex])
        }
        return ""
    }
    
    /// Returns the name of the file.
    public var name: String {
        return URL(fileURLWithPath: id).deletingPathExtension().lastPathComponent
    }
    
    /// A textual representation of this file information.
    public var description: String { id }
    
    /// Creates an instance of the file information.
    /// - Parameter fileID: Pass value of the `#fileID` literal.
    public init(fileID: String = #fileID) {
        self.id = fileID
    }
    
}
