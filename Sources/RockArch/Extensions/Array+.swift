internal extension Array where Element: Equatable {
    
    /// Returns an array containing all but duplicates.
    ///
    ///     let array = [1, 2, 2, 4, 5, 5, 5]
    ///     array.removedDuplicates() // [1, 2, 4, 5]
    ///
    func removedDuplicates() -> [Element] {
        var result = [Element]()
        forEach { if !result.contains($0) { result.append($0) } }
        return result
    }
    
}
