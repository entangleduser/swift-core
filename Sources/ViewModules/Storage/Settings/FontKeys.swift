import Storage

public struct FontFamilyKey: SettingsKey {
 public typealias Value = String?
 public init() {}
}

extension Settings {
 public var fontFamily: String? {
  get { self[FontFamilyKey.self] }
  set { self[FontFamilyKey.self] = newValue }
 }
}
