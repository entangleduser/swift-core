import struct Foundation.Date

@available(macOS 10.9, *, iOS 14.0, *)
extension Date: Infallible {
 @_transparent @_disfavoredOverload
 public static var now: Date { Date() }
 public static let defaultValue: Self = .now
}
