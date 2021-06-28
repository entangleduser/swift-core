import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public class Settings: StateObservable {
  @Published
  public var state: PublisherState = .initialize {
    willSet { objectWillChange.send() }
  }

  public let defaults: UserDefaults


  public subscript<Key: SettingsKey>(
    _: KeyPath<Settings, Key>
  ) -> Key.Value {
    get { defaults[Key.self] }
    set {
      update { [weak self] in
        self?.defaults[Key.self] = newValue
      }
    }
  }
  public subscript<Key: SettingsKey>(
    _: Key.Type
  ) -> Key.Value {
    get { defaults[Key.self] }
    set {
      update { [weak self] in
        self?.defaults[Key.self] = newValue
      }
    }
  }

  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }
}

@available(macOS 10.15, iOS 13.0, *)
public extension Settings {
  static let shared = Settings()
}
