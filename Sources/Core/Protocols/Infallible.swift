//postfix operator ~
/// A type that has a default value.
public protocol Infallible {
  static var defaultValue: Self { get }
}

//public extension Infallible {
//	@_transparent @inline(__always)
//	static postfix func ~(_ type: Self.Type) -> Self { defaultValue }
//}

public extension Optional where Wrapped: Infallible {
	@_transparent @inline(__always)
	var unwrapped: Wrapped { self ?? .defaultValue }
//	@_transparent @inline(__always)
//	static postfix func ~(_ value: Self) -> Wrapped { value.unwrapped }
}

// MARK: Conformance Helpers
// FIXME: Conform to protocol `Infallible`
extension ExpressibleByNilLiteral {
	@_transparent @inline(__always)
	public static var defaultValue: Self { nil }
}

extension ExpressibleAsEmpty {
	@_transparent @inline(__always)
	public static var defaultValue: Self { empty }

}

extension ExpressibleAsZero {
	@_transparent @inline(__always)
	public static var defaultValue: Self { zero }
}

