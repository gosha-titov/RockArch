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
    
}
