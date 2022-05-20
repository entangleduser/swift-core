/// A collection type that can be expressed as empty.
public protocol ExpressibleAsEmpty: Infallible {
 static var empty: Self { get }
}

extension ExpressibleAsEmpty where Self: Equatable {
 @_disfavoredOverload
 @_transparent @inline(__always)
 var isEmpty: Bool { self == .empty }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `ExpressibleAsEmpty`
public extension ExpressibleByArrayLiteral {
 @_transparent @inline(__always)
 static var empty: Self { [] }
}

public extension ExpressibleByStringLiteral {
 @_transparent @inline(__always)
 static var empty: Self { "" }
}

public extension ExpressibleByDictionaryLiteral {
 @_transparent @inline(__always)
 static var empty: Self { [:] }
}

// MARK: Conforming Types
extension String: ExpressibleAsEmpty {}

extension Dictionary: ExpressibleAsEmpty {}

extension Array: ExpressibleAsEmpty {}
