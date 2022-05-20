import Storage

public struct ShutterSoundKey: SettingsKey {
 public typealias Value = Bool
 public static let defaultValue: Bool = true
 public init() {}
}

public extension Settings {
 var enableShutterSound: Bool! {
  get { self[ShutterSoundKey.self] }
  set { self[ShutterSoundKey.self] = newValue }
 }
}



