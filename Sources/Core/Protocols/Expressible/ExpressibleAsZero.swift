/// A numeric type that can be expressed as zero.
public protocol ExpressibleAsZero: Infallible {
 static var zero: Self { get }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `ExpressibleAsZero`
public extension ExpressibleByFloatLiteral {
 @_transparent @inline(__always)
 static var zero: Self { 0.0 }
}

public extension ExpressibleByIntegerLiteral {
 @_transparent @inline(__always)
 static var zero: Self { 0 }
}

// MARK: Conforming Types
extension Int: ExpressibleAsZero {}
