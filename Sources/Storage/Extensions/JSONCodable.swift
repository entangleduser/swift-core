import Foundation

public protocol JSONCodable: AutoCodable {}

public extension JSONCodable {
	static var decoder: JSONDecoder { JSONDecoder() }
	static var encoder: JSONEncoder { JSONEncoder() }
	init(_ dictionary: [AnyHashable: Any]) throws {
		let data =
			try JSONSerialization.data(withJSONObject: dictionary, options: [.fragmentsAllowed])
		self = try Self.decoder.decode(Self.self, from: data)
	}

	var dictionary: [String: Any]? {
		guard let data = data else { return nil }
		return try? JSONSerialization
			.jsonObject(with: data, options: [.fragmentsAllowed, .mutableLeaves, .allowFragments])
			as? [String: Any]
	}
}
