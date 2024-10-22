internal extension Array {
    
    /// Returns a new array with the specified element appended.
    ///
    ///     let array = [0, 1]
    ///     array.appending(2) // [0, 1, 2]
    ///
    @inlinable func appending(_ element: Element) -> Self {
        return self + [element]
    }
    
}


internal extension Array where Element: Equatable {
    
    /// Returns a new array containing all but duplicates, leaving only the first element of them.
    ///
    ///     let array = [1, 2, 3, 2, 4, 4, 5, 4]
    ///     array.removingDuplicates() // [1, 2, 3, 4, 5]
    ///
    @inlinable func removingDuplicates() -> Self {
        var result = [Element]()
        forEach { if !result.contains($0) { result.append($0) } }
        return result
    }
    
    /// Removes all duplicate elements, leaving only the first element of them.
    ///
    ///     var array = [1, 2, 3, 2, 4, 4, 5, 4]
    ///     array.removeDuplicates() // [1, 2, 3, 4, 5]
    ///
    @inlinable mutating func removeDuplicates() -> Void {
        self = removingDuplicates()
    }
    
    /// Returns a boolean value that indicates whether the sequence contains all the given elements.
    ///
    ///     let array = [3, 1, 4, 1, 5]
    ///     array.contains([5, 4, 6]) // false
    ///     array.contains([5, 4])    // true
    ///
    /// - Parameter elements: The elements to find in the sequence.
    /// - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
    @inlinable func contains(_ elements: [Element]) -> Bool {
        for element in elements {
            guard contains(element) else { return false }
        }
        return true
    }
    
}


internal extension Array where Element: CustomStringConvertible {
    
    /// Returns a string by converting the elements of the sequence to strings and concatenating them, adding the given separator between each element.
    ///
    ///     [1.2, 3.4, 5.6].toString(separator: " ") // "1.2 3.4 5.6"
    ///     [1, 2, 3].toString(separator: ", ") // "1, 2, 3"
    ///
    /// - Parameter separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
    @inlinable func toString(separator: String = "") -> String {
        return map { $0.description }.joined(separator: separator)
    }
    
}


internal extension Array where Element: RARouter {
    
    @inlinable mutating func removeChildren(upToAndIncluding child: RARouter) -> Void {
        guard contains(where: { $0 === child } ) else { return }
        for currentChild in self {
            removeLast()
            guard currentChild !== child else { break }
        }
    }
    
}
