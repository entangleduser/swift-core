import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public protocol StorageWrapper: BaseStorage, DynamicProperty {
 associatedtype Key: Hashable
 var wrappedValue: [Key: Value] { get nonmutating set }
 @available(iOS 13.0, *)
 var projectedValue: Binding<[Key: Value]> { get }
}

@available(macOS 10.15, iOS 13.0, *)
public extension StorageWrapper where Value: Identifiable, Value.ID == Key {
 subscript(_ id: Value.ID) -> Value? {
  get { wrappedValue[id] }
  nonmutating set { wrappedValue[id] = newValue }
 }
}

@available(macOS 10.15, iOS 13.0, *)
public extension StorageWrapper where Key == AnyHashable {
 subscript(_ key: Key) -> Value? {
  get { wrappedValue[key] }
  nonmutating set { wrappedValue[key] = newValue }
 }
}
