import Storage

public struct ShowCompassKey: SettingsKey {
 public typealias Value = Bool
 public static let defaultValue: Bool = true
 public init() {}
}

public extension Settings {
 var showCompass: Bool! {
  get { self[ShowCompassKey.self] }
  set { self[ShowCompassKey.self] = newValue }
 }
}

