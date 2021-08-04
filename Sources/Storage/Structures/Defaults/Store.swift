import protocol Core.Infallible
import SwiftUI

/// A `UserDefaults` wrapper for object that conform to `AutoCodable`.
@propertyWrapper
public struct Store<Value: AutoCodable & Infallible>: DefaultsWrapper {
	public var store: UserDefaults = .standard
	public let key: String
	public let defaultValue: Value?
	public var wrappedValue: Value {
		get {
			do {
				guard let data = store.data(forKey: key) else {
					return defaultValue.unwrapped
				}
				return try Value.decoder.decode(Value.self, from: data)
			} catch {
				debugPrint(
					Error<Value>.read(
						description: error.localizedDescription
					)
				)
			}
			return defaultValue.unwrapped
		}
		nonmutating set {
			do {
				let data = try Value.encoder.encode(newValue)
				store.set(data, forKey: key)
			} catch {
				debugPrint(
					Error<Value>.write(
						description: error.localizedDescription)
				)
			}
		}
	}

	public var projectedValue: Binding<Value> {
		Binding<Value>(
			get: { self.wrappedValue },
			set: { self.wrappedValue = $0 }
		)
	}

	public init(
		wrappedValue: Value? = .none,
		_ key: String,
		store: UserDefaults? = nil
	) {
		if let store = store { self.store = store }
		self.key = key
		self.defaultValue = wrappedValue
	}
	public func update() {}
}

// MARK: - Error-Handling
@available(macOS 10.15, iOS 13.0, *)
extension Store {
	enum Error<Value>: LocalizedError {
		case read(description: String),
		     write(description: String)

		static var prefix: String { "\(Self.self): " }

		var failureReason: String? {
			switch self {
			case let .read(description):
				return description
			case let .write(description):
				return description
			}
		}

		var errorDescription: String? {
			switch self {
			case .read:
				return "Read." + Self.prefix
					.appending(failureReason!)
			case .write:
				return "Write." + Self.prefix
					.appending(failureReason!)
			}
		}
	}
}


@available(macOS 10.15, iOS 13.0, *)
extension Store: AutoCodable {
	public init(from decoder: Decoder) throws {
		fatalError()
		/*try self.init(from: decoder)
		if let data =
			store.data(forKey: key) {
			wrappedValue =
				try Self.decoder.decode(Value.self, from: data)
		}*/
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		try container.encode(wrappedValue)
	}

	public static var decoder: Value.AutoDecoder { Value.decoder }
	public static var encoder: Value.AutoEncoder { Value.encoder }
}

