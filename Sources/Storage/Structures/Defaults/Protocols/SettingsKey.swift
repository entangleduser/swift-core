import protocol Core.Infallible

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
}
