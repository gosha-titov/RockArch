import Foundation

/// The file information in which it's created.
///
/// For example, you create a file information inside `TestProject/ViewControllers/ViewController.swift`:
///
///     let file = RAFileInfo()
///     file.id     // "TestProject/ViewController.swift"
///     file.module // "TestProject"
///     file.name   // "ViewController"
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
    /// - Parameter id: Pass value of the `#fileID` literal.
    public init(id: String = #fileID) {
        self.id = id
    }
    
}
