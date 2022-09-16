import Algorithms
import Foundation

// MARK: Transforming
public extension Collection {
 #if canImport(Dispatch)
 @inlinable
 @_disfavoredOverload func parallelMap<R>(
  _ transform: @escaping (Element) throws -> R
 ) rethrows -> [R] {
  var res: [R] = .empty
  let lock = NSRecursiveLock()
  DispatchQueue.concurrentPerform(iterations: count) { i in
   do {
    lock.lock()
    try res.append(transform(self[index(startIndex, offsetBy: i)]))
    lock.unlock()
   } catch { debugPrint(error.localizedDescription) }
  }
  return res
 }

 #if canImport(_Concurrency) || canImport(Concurrency)
 // https://www.swiftbysundell.com/articles/async-and-concurrent-forEach-and-map/
  @inlinable @_disfavoredOverload func map<T>(
   _ transform: @Sendable @escaping (Element) async throws -> T
  ) async rethrows -> [T] where Element: Sendable {
   var values = [T]()

   for element in self {
    try await values.append(transform(element))
   }

   return values
  }

  @inlinable @_disfavoredOverload func compactMap<T>(
   _ transform: @Sendable (Element) async throws -> T?
  ) async rethrows -> [T] where T: Sendable, Element: Sendable {
   var values = [T]()

   for element in self {
    guard let value = try await transform(element) else { continue }
    values.append(value)
   }

   return values
  }

  @inlinable @_disfavoredOverload func concurrentMap<T>(
   _ transform: @Sendable @escaping (Element) async throws -> T
  ) async throws -> [T] where T: Sendable, Element: Sendable {
   let tasks = map { element in
    Task {
     try await transform(element)
    }
   }
   return try await tasks.map { task in
    try await task.value
   }
  }

  @inlinable func concurrentMap<T>(
   _ transform: @Sendable @escaping (Element) async throws -> T?
  ) async throws -> [T] where T: Sendable, Element: Sendable {
   let tasks = map { element in
    Task {
     try await transform(element)
    }
   }
   return try await tasks.compactMap { task in
    try await task.value
   }
  }
 #endif
 @inlinable func parallelMap<R>(_ transform: @escaping (Element) throws -> R?) rethrows -> [R] {
  var res: [R?] = .init(repeating: .none, count: count)
  let lock = NSRecursiveLock()
  DispatchQueue.concurrentPerform(iterations: count) { i in
   do {
    lock.lock()
    if let value = try transform(self[index(startIndex, offsetBy: i)]) {
     res[i] = value
    }
    lock.unlock()
   } catch { debugPrint(error.localizedDescription) }
  }
  return res.compactMap { $0 }
  // return try self.parallelMap({ try transform($0) }).compactMap { $0 }
 }

// @inlinable func parallelFilter(
//  _ isIncluded: @escaping (Element) throws -> Bool) rethrows -> [Element] {
 ////   var res: [R] = .empty
 ////   let lock = NSRecursiveLock()
 ////   DispatchQueue.concurrentPerform(iterations: count) { i in
 ////    do {
 ////     lock.lock()
 ////     try res.append(transform(self[index(startIndex, offsetBy: i)]))
 ////     lock.unlock()
 ////    } catch { debugPrint(error.localizedDescription) }
 ////   }
 ////
//  return try parallelMap { try isIncluded($0) != nil ? $0 : .none }
// }

 @inlinable func parallelFilter(
  _ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
  var res: [Element] = .empty
  let lock = NSRecursiveLock()
  DispatchQueue.concurrentPerform(iterations: count) { i in
   do {
    lock.lock()
    let value = self[index(startIndex, offsetBy: i)]
    if try isIncluded(value) {
     res.append(value)
    }
    lock.unlock()
   } catch { debugPrint(error.localizedDescription) }
  }
  return res
 }

 @inlinable func parallelPerform(
  _ transform: (Element) throws -> ()) rethrows {
  let lock = NSRecursiveLock()
  DispatchQueue.concurrentPerform(iterations: count) { i in
   do {
    lock.lock()
    try transform(self[index(startIndex, offsetBy: i)])
    lock.unlock()
   } catch { debugPrint(error.localizedDescription) }
  }
 }
 #endif
}

// MARK: Indexing
public extension Collection {
 @_transparent
 var notEmpty: Bool { isEmpty == false }
 var wrapped: Self? {
  isEmpty ? .none : self
 }
}

#if canImport(SwiftUI)
 import SwiftUI

 public extension Array {
  @discardableResult mutating func trim(_ index: Index) -> Self {
   guard endIndex > index else { return self }
   let indexes = IndexSet(integersIn: index ..< endIndex)
   remove(atOffsets: indexes)
   return self
  }
 }
#endif

// MARK: Uniquing
public extension RandomAccessCollection where Iterator.Element: Hashable {
 func unique() -> [Iterator.Element] {
  var seen: Set<Iterator.Element> = []
  return filter { seen.insert($0).inserted }
 }
}

public extension Array where Element: Hashable {
 @discardableResult mutating func removeDuplicates() -> Self {
  self = unique()
  return self
 }

 @discardableResult mutating func appendUnique(_ element: Element) -> Self {
  if !contains(element) { append(element) }
  return self
 }
}

public struct OptionSetIterator<Set, Element>: IteratorProtocol
where Set: OptionSet, Element: FixedWidthInteger, Set.RawValue == Element {
 private let value: Set
 private lazy var remainingBits = value.rawValue
 private var bitMask: Element = 1
 
 public init(element: Set) {
  value = element
 }
 
 public mutating func next() -> Set? {
  while remainingBits != 0 {
   defer { bitMask = bitMask &* 2 }
   if remainingBits & bitMask != 0 {
    remainingBits = remainingBits & ~bitMask
    return Set(rawValue: bitMask)
   }
  }
  return nil
 }
}

public extension OptionSet where RawValue: FixedWidthInteger {
 func makeIterator() -> OptionSetIterator<Self, RawValue> {
  OptionSetIterator(element: self)
 }
}
