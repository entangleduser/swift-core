import protocol Core.Infallible

@_typeEraser(AnySettingsKey)
public protocol SettingsKey: Hashable, CustomStringConvertible {
 associatedtype Value
 static var defaultValue: Value { get }
 init()
}

public extension SettingsKey {
 var description: String {
  String(describing: Self.self)
 }
}

public extension SettingsKey where Value: Infallible {
 static var defaultValue: Value { .defaultValue }
 @_disfavoredOverload init() { self.init() }
}

public struct AnySettingsKey:
 ExpressibleByStringLiteral, SettingsKey, Infallible {
 internal init(description: String = .empty) {
  self.description = description
 }
 
 public init() {}
 public typealias Value = Self
 public var description: String = .empty
 public init(stringLiteral value: String) {
  self.init(description: value)
 }
 public init<K: SettingsKey>(erasing: K) {
  self.description = erasing.description
 }
}

extension Settings {
 @resultBuilder
 public enum Builder {
//  public static func buildBlock(
//   _ components: AnySettingsKey...
//  ) -> [AnySettingsKey] { components }
  public static func buildBlock(
   _ array: String...
  ) -> [AnySettingsKey] { array.map({ .init(description: $0) }) }
 }
}
