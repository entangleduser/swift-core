/// A container for performing functions based on unique values.
public protocol KeyValueCollection: KeyValuable {
 typealias Base = [Key: Value]
 var _elements: Base { get nonmutating set }
}

public extension KeyValueCollection {
 @_transparent @inline(__always)
 func contains(_ key: Key) -> Bool {
  _elements[key] != nil
 }

 @_transparent @inline(__always)
 func contains(_: Value) -> Bool {
  _elements.keys.contains(where: { _elements[$0] != nil })
 }

 @inline(__always)
 subscript(_ key: Key) -> Value? {
  get { _elements[key] }
  nonmutating set { _elements[key] = newValue }
 }
}

// MARK: Conformance Helpers
public extension KeyValueCollection where Key == Int, Value: Hashable {
 @_transparent @inline(__always)
 mutating func append(_ value: Value) {
  _elements[value.hashValue] = value
 }

 @_transparent @inline(__always)
 mutating func append(_ values: [Value]) {
  values.forEach { append($0) }
 }

 init(_ values: [Base.Value]) {
  self.init()
  append(values)
 }

 init(arrayLiteral elements: Value...) {
  self.init(elements)
 }
}

public extension KeyValueCollection where Key == Value.ID, Value: Identifiable {
 @_transparent @inline(__always)
 mutating func append(_ value: Value) {
  _elements[value.id] = value
 }
}
