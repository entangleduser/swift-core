import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
open class Settings: StateObservable {
  @Published
	open var state: PublisherState = .initialize {
    willSet { objectWillChange.send() }
  }

	public let defaults: UserDefaults

	open func reset() {
		defaults.dictionaryRepresentation().keys
			.forEach { defaults.removeObject(forKey: $0) }
	}
	open func remove<Key: SettingsKey>(_ path: KeyPath<Settings, Key>) {
		defaults.removeObject(forKey: self[keyPath: path].description) 
	}
	public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }
}

@available(macOS 10.15, iOS 13.0, *)
public extension Settings {
	static let shared = Settings()
	/// Gets value for key based on `Hashable` key values.
	func get<Key: SettingsKey>(for key: Key) -> Key.Value {
		defaults.value(forKey: key.description) as? Key.Value ?? Key.defaultValue
	}

	/// Sets value for key based on key values.
	func set<Key: SettingsKey>(_ value: Key.Value?, for key: Key) {
		defaults.setValue(value, forKey: key.description)
	}

	func getCodable<Key: SettingsKey>(for key: Key) -> Key.Value
	where Key.Value: AutoCodable {
		if let data =
				(defaults.value(forKey: key.description) as? Key.Value.AutoDecoder.Input),
			let value = try? Key.Value.decoder
			.decode(Key.Value.self, from: data) {
			return value
		}
		return Key.defaultValue
	}

	func setCodable<Key: SettingsKey>(_ value: Key.Value?, for key: Key)
		where Key.Value: AutoCodable {
		try? defaults.setValue(value?.encoded(), forKey: key.description)
	}

	func getCodableArray<Key: SettingsKey>(for key: Key) -> [Key.Value]
	where Key.Value: AutoCodable {
		if let data =
				(defaults.value(forKey: key.description) as? [Key.Value.AutoDecoder.Input]),
			let value = try? Key.Value.decoder
			.decode(Key.Value.self, fromArray: data) {
			return value
		}
		return .empty
	}

	func setCodableArray<Key: SettingsKey>(_ value: [Key.Value]?, for key: Key)
		where Key.Value: AutoCodable {
		try? defaults.setValue(value?.map { try $0.encoded() }, forKey: key.description)
	}


}
