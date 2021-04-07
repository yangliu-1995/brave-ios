/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

extension Array where Element: Comparable {
    public func sameElements(_ arr: [Element]) -> Bool {
        guard self.count == arr.count else { return false }
        let sorted = self.sorted(by: <)
        let arrSorted = arr.sorted(by: <)
        for elements in sorted.zip(arrSorted) where elements.0 != elements.1 {
            return false
        }
        return true
    }
}

extension Array {

    public func find(_ f: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for x in self {
            if f(x) {
                return x
            }
        }
        return nil
    }

    public func contains(_ x: Element, f: (Element, Element) -> Bool) -> Bool {
        for y in self {
            if f(x, y) {
                return true
            }
        }
        return false
    }

    // Performs a union operator using the result of f(Element) as the value to base uniqueness on.
    public func union<T: Hashable>(_ arr: [Element], f: ((Element) -> T)) -> [Element] {
        let result = self + arr
        return result.unique(f)
    }

    // Returns unique values in an array using the result of f()
    public func unique<T: Hashable>(_ f: ((Element) -> T)) -> [Element] {
        var map: [T: Element] = [T: Element]()
        return self.compactMap { a in
            let t = f(a)
            if map[t] == nil {
                map[t] = a
                return a
            } else {
                return nil
            }
        }
    }

    /// Returns a unique list of Elements using a custom comparator.
    /// Super inefficient.
    public func unique(f: (Element, Element) -> Bool) -> [Element] {
        var result = [Element]()
        self.forEach {
            if !result.contains($0, f: f) {
                result.append($0)
            }
        }
        return result
    }

    /// Splits an array into smaller arrays.
    /// For example `[1, 2, 3 ,4 ,5 ,6].splitEvery(3)`
    /// results in `[[1, 2, 3], [4, 5, 6]]`
    public func splitEvery(_ n: Int) -> [[Element]] {
        if n <= 0 || isEmpty { return [] }
        if n >= count { return [self] }

        return stride(from: 0, to: self.count, by: n).map {
            Array(self[$0..<Swift.min($0 + n, self.count)])
        }
    }
}

extension Sequence {
    public func every(_ f: (Self.Iterator.Element) -> Bool) -> Bool {
        for x in self {
            if !f(x) {
                return false
            }
        }
        return true
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
