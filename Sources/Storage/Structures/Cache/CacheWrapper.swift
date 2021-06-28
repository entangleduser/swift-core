import SwiftUI

/// A property wrapper for dynamically caching objects.
@available(macOS 10.15, iOS 13.0, *)
public protocol CacheWrapper: StorageWrapper, BaseCache {}

@available(macOS 10.15, iOS 13.0, *)
public extension CacheWrapper {
	func clear() throws {
		try Self.clear()
	}
}
