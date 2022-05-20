import Storage

public struct CurrentTabKey: SettingsKey {
 public typealias Value = Int
 public init() {}
}

public extension Settings {
 var currentTab: Int! {
  get { self[CurrentTabKey.self] }
  set { self[CurrentTabKey.self] = newValue }
 }
}

