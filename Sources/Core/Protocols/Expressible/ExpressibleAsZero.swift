/// A numeric type that can be expressed as zero.
public protocol ExpressibleAsZero: Infallible {
	static var zero: Self { get }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `ExpressibleAsZero`
extension ExpressibleByFloatLiteral {
	@_transparent @inline(__always)
	public static var zero: Self { 0.0 }
}

extension ExpressibleByIntegerLiteral {
	@_transparent @inline(__always)
	public static var zero: Self { 0 }
}

// MARK: Conforming Types
extension Int: ExpressibleAsZero {}
