import protocol Core.KeyValueCollection
import protocol Core.Infallible
/// A location-based storage intended to be inherited by an environment object.
open class LocationStorage<Entry>: KeyValueCollection {
	public typealias Key = AnyHashable
	public typealias Value = Entry
	open var _elements: Base = .empty

	public subscript<Location, Value, Key>(
		_ location: Location,
		_ dynamicMember: KeyPath<Location, Value>,
		_ keyPath: KeyPath<Value, Key>
	) -> Entry?
		where Key: Hashable {
		get {
			_elements[
				location[
					keyPath: dynamicMember.appending(path: keyPath)
				]
			]
		}
		set {
			_elements[
				location[
					keyPath: dynamicMember.appending(path: keyPath)
				]
			] = newValue
		}
	}

	public required init() {}
}
