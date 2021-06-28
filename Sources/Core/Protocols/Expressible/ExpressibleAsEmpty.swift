/// A collection type that can be expressed as empty.
public protocol ExpressibleAsEmpty: Infallible {
	static var empty: Self { get }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `ExpressibleAsEmpty`
extension ExpressibleByArrayLiteral {
	@_transparent @inline(__always)
	public static var empty: Self { [] }
}

extension ExpressibleByStringLiteral {
	@_transparent @inline(__always)
	public static var empty: Self { "" }
}

extension ExpressibleByDictionaryLiteral {
	@_transparent @inline(__always)
	public static var empty: Self { [:] }
}

// MARK: Conforming Types
extension String: ExpressibleAsEmpty {}

extension Dictionary: ExpressibleAsEmpty {}

extension Array: ExpressibleAsEmpty {}
