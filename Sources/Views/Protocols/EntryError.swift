import Foundation

public protocol EntryError:
 Identifiable,
 Hashable,
 LocalizedError,
 CustomStringConvertible {}

public extension EntryError {
 var id: String { String(hashValue) }
 var errorDescription: String? { failureReason }
 var localizedDescription: String { failureReason.unwrapped }
 var description: String { failureReason.unwrapped }
}
