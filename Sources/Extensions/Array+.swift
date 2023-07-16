internal extension Array where Element: Equatable {
    
    /// Returns an array containing all but duplicates, leaving only the first element of them.
    ///
    ///     let array = [1, 2, 3, 2, 4, 4, 5, 4]
    ///     array.removedDuplicates() // [1, 2, 3, 4, 5]
    ///
    func removedDuplicates() -> [Element] {
        var result = [Element]()
        forEach { if !result.contains($0) { result.append($0) } }
        return result
    }
    
    /// Removes all duplicate elements, leaving only the first element of them.
    ///
    ///     var array = [1, 2, 3, 2, 4, 4, 5, 4]
    ///     array.removeDuplicates() // [1, 2, 3, 4, 5]
    ///
    mutating func removeDuplicates() -> Void {
        self = removedDuplicates()
    }
    
    /// Returns a boolean value that indicates whether the sequence contains all the given elements.
    ///
    ///     let array = [3, 1, 4, 1, 5]
    ///     array.contains([5, 4, 6]) // false
    ///     array.contains([5, 4])    // true
    ///
    /// - Parameter elements: The elements to find in the sequence.
    /// - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
    func contains(_ elements: [Element]) -> Bool {
        for element in elements {
            guard contains(element) else { return false }
        }
        return true
    }
    
}
