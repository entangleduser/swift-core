import Foundation

public protocol CacheExpirable {
	var timestamp: Date { get set }
	static var expiration: TimeInterval? { get }
}
