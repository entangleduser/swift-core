public protocol KeyIdentifiable {
	/// A type representing the stable identity of the entity associated with
	/// an instance.
	associatedtype Key: Hashable
	/// The stable identity of the entity associated with this instance.
	@inline(__always)
	var key: Key { get }
}

public extension KeyIdentifiable where Self: Identifiable {
		var id: Key { key }
}
