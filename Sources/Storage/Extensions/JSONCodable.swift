import Foundation
@available(macOS 10.15, iOS 13.0, *)
public protocol JSONCodable: AutoCodable {}

@available(macOS 10.15, iOS 13.0, *)
public extension JSONCodable {
	static var decoder: JSONDecoder { JSONDecoder() }
	static var encoder: JSONEncoder { JSONEncoder() }
}
