import Foundation

public protocol CacheExpirable {
 static var expiration: TimeInterval? { get }
}

public extension CacheExpirable {
 static var expiration: TimeInterval? { 15_552_000 } // 180 days
}
