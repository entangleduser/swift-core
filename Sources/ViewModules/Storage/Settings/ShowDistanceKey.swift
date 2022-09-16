import Storage

public struct ShowDistanceKey: SettingsKey {
 public typealias Value = Bool
 public static let defaultValue: Bool = true
 public init() {}
}

public extension Settings {
 var showDistance: Bool! {
  get { self[ShowDistanceKey.self] }
  set { self[ShowDistanceKey.self] = newValue }
 }
}


