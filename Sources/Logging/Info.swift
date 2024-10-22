import Foundation

/// The information about a file, function and line this instance originates from.
///
/// For example, you create the `RAInfo` instance inside `TestProject/ViewControllers/ViewController.swift`:
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
///
///             print(info)
///             // Prints "file: TestProject/ViewController.swift | func: viewDidLoad() | line: 8"
///         }
///
///     }
///
/// The `RAInfo` instance is mainly used in log messages.
public struct RAInfo: Equatable, Codable {
    
    /// The information about a file.
    public let file: RAFileInfo
    
    /// The name of a function.
    public let function: String
    
    /// The number of a line.
    public let line: Int
    
    /// Creates an instance of the information about a file, function and line.
    /// - Parameter fileID:   Pass value of the `#fileID` literal.
    /// - Parameter function: Pass value of the `#function` literal.
    /// - Parameter line:     Pass value of the `#line` literal.
    public init(fileID: String = #fileID, function: String = #function, line: Int = #line) {
        file = RAFileInfo(fileID: fileID)
        self.function = function
        self.line = line
    }
    
}



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
/// The `RAFileInfo` instance is mainly used in log messages.
public struct RAFileInfo: Equatable, Codable {
    
    /// The name of the module and file. It's the same as `#fileID`.
    public let id: String
    
    /// The name of a module this file originates from.
    @inlinable public var module: String? {
        return if let slashIndex = id.firstIndex(of: "/") {
            String(id[..<slashIndex])
        } else { nil }
    }
    
    /// The name of a file.
    @inlinable public var name: String {
        return URL(fileURLWithPath: id).deletingPathExtension().lastPathComponent
    }
    
    /// Creates an instance of the file information.
    /// - Parameter fileID: Pass value of the `fileID` literal.
    public init(fileID: String = #fileID) {
        id = fileID
    }
    
}



// MARK: - CustomStringConvertible

extension RAInfo: CustomStringConvertible {
    
    /// A textual representation of this information.
    public var description: String {
        return "file: \(file) | func: \(function) | line: \(line)"
    }
    
}


extension RAFileInfo: CustomStringConvertible {
    
    /// A textual representation of this file information.
    ///
    /// Returns a value of the `id` property.
    public var description: String { id }
    
}



// MARK: - Extensions

extension RAInfo {
    
    public static func == (lhs: RAInfo, rhs: RAInfo) -> Bool {
        return lhs.file == rhs.file && lhs.function == rhs.function && lhs.line == rhs.line
    }
    
}

extension RAFileInfo {
    
    public static func == (lhs: RAFileInfo, rhs: RAFileInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
}
