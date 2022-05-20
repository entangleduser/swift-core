// postfix operator ~
/// A type that has a default value.
public protocol Infallible {
 static var defaultValue: Self { get }
}

// public extension Infallible {
//	@_transparent @inline(__always)
//	static postfix func ~(_ type: Self.Type) -> Self { defaultValue }
// }

extension Optional: Infallible where Wrapped: Infallible {
 @_transparent @inline(__always)
 public var unwrapped: Wrapped { self ?? .defaultValue }
 //	@_transparent @inline(__always)
 //	static postfix func ~(_ value: Self) -> Wrapped { value.unwrapped }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `Infallible`
public extension ExpressibleByNilLiteral {
 @_transparent @inline(__always)
 static var defaultValue: Self { nil }
}

public extension ExpressibleAsEmpty {
 @_transparent @inline(__always)
 static var defaultValue: Self { empty }
}

public extension ExpressibleAsZero {
 @_transparent @inline(__always)
 static var defaultValue: Self { zero }
}
