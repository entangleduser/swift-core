import protocol Core.Infallible
import SwiftUI

/// A non-failiable wrapper for `UserDefaults`
@propertyWrapper
public struct Storage<Value>: DefaultsWrapper where Value: Infallible {
	public var store: UserDefaults = .standard
	public let key: String
	public var wrappedValue: Value {
		get { (store.object(forKey: key) as? Value).unwrapped }
		nonmutating set { store.set(newValue, forKey: key) }
	}

	@available(macOS 10.15, iOS 13.0, *)
	public var projectedValue: Binding<Value> {
		Binding<Value>(
			get: { self.wrappedValue },
			set: { self.wrappedValue = $0 }
		)
	}

	public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) {
		self.key = key
		if let store = store { self.store = store }
		if self.store.object(forKey: key) == nil {
			self.wrappedValue = wrappedValue
		}
	}
}
