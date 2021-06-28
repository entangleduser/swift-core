/// A type that has a default value.
public protocol Infallible {
  static var defaultValue: Self { get }
}

extension Optional where Wrapped: Infallible {
	@_transparent @inline(__always)
	public var unwrapped: Wrapped { self ?? .defaultValue }
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
