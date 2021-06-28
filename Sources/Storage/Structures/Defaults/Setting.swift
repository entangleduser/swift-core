import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
@propertyWrapper
@dynamicMemberLookup
public struct Setting<Key>: SettingsWrapper where Key: SettingsKey {
	let path: KeyPath<Settings, Key>
	public let settings: Settings

	public var wrappedValue: Key.Value {
		get { self[dynamicMember: path] }
		nonmutating set {
			settings.update {
				self[dynamicMember: path] = newValue
			}
		}
	}

	public var projectedValue: Binding<Key.Value> {
		Binding<Key.Value>(
			get: { self.wrappedValue },
			set: { newValue in self.wrappedValue = newValue }
		)
	}

	public subscript(
		dynamicMember keyPath: KeyPath<Settings, Key>
	) -> Key.Value {
		get { self[settings[keyPath: keyPath]] }
		nonmutating set { self[settings[keyPath: keyPath]] = newValue }
	}

	public init(
		wrappedValue _: Key.Value = Key.defaultValue,
		_ path: KeyPath<Settings, Key>,
		settings: Settings = .shared
	) where Key: SettingsKey {
		self.path = path
		self.settings = settings
	}
}

public extension Setting {
	@propertyWrapper
	@dynamicMemberLookup
	struct Codable: SettingsWrapper where Key.Value: AutoCodable {
		let path: KeyPath<Settings, Key>
		public var settings: Settings = .shared

		public var wrappedValue: Key.Value {
			get { self[dynamicMember: path] }
			nonmutating set {
				settings.update {
					self[dynamicMember: path] = newValue
				}
			}
		}

		public var projectedValue: Binding<Key.Value> {
			Binding<Key.Value>(
				get: { self.wrappedValue },
				set: { newValue in self.wrappedValue = newValue }
			)
		}

		public subscript(
			dynamicMember keyPath: KeyPath<Settings, Key>
		) -> Key.Value {
			get { self[settings[keyPath: keyPath]] }
			nonmutating set { self[settings[keyPath: keyPath]] = newValue }
		}

		public init(
			wrappedValue _: Key.Value = Key.defaultValue,
			_ path: KeyPath<Settings, Key>,
			settings: Settings = .shared
		) where Key: SettingsKey {
			self.path = path
			self.settings = settings
		}

		@propertyWrapper
		@dynamicMemberLookup
		public struct Set: SettingsWrapper where Key.Value: AutoCodable {
			public var settings: Settings = .shared
			let path: KeyPath<Settings, Key>
			let defaultValue: [Key.Value]
			public var wrappedValue: [Key.Value] {
				get {
					if
						!defaultValue.isEmpty,
						settings.defaults.object(forKey: Key().description) == nil {
						self[settings[keyPath: path]] = defaultValue
						return defaultValue
					}
					return self[dynamicMember: path]
				}
				nonmutating set {
					settings.update {
						self[dynamicMember: path] = newValue
					}
				}
			}

			public var projectedValue: Binding<[Key.Value]> {
				Binding<[Key.Value]>(
					get: { self.wrappedValue },
					set: { newValue in self.wrappedValue = newValue }
				)
			}

			public subscript(
				dynamicMember keyPath: KeyPath<Settings, Key>
			) -> [Key.Value] {
				get { self[settings[keyPath: keyPath]] }
				nonmutating set { self[settings[keyPath: keyPath]] = newValue }
			}

			public init(
				wrappedValue: [Key.Value] = .empty,
				_ path: KeyPath<Settings, Key>,
				settings: Settings = .shared
			) where Key: SettingsKey {
				self.settings = settings
				self.path = path
				self.defaultValue = wrappedValue
			}
		}
	}
}

public extension Setting.Codable {
	subscript(_ key: Key) -> Key.Value {
		get { settings.getCodable(for: key) }
		nonmutating set { settings.setCodable(newValue, for: key) }
	}
}

public extension Setting.Codable.Set {
	subscript(_ key: Key) -> [Key.Value] {
		get { settings.getCodableArray(for: key) }
		nonmutating set { settings.setCodableArray(newValue, for: key) }
	}
}
