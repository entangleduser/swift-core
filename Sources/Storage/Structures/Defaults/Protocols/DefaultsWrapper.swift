import SwiftUI

/// A single / multiple value property wrapper for any `UserDefaults` storage.
@available(macOS 10.15, iOS 13.0, *)
public protocol DefaultsWrapper: DynamicProperty {
 associatedtype Value
 var store: UserDefaults { get set }
 var key: String { get }
}

@available(macOS 10.15, iOS 13.0, *)
public extension DefaultsWrapper {
 func clear() {
  store.removeObject(forKey: key)
 }
}
