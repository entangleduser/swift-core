import Combine
import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
@propertyWrapper
@dynamicMemberLookup
public struct Setting<Value>: DynamicProperty where Value: Equatable {
 /// Optional key path to remove without referencing settings.
 /// Extensions to this must be non-optional to be unwrapped automatically.
 /// - Note:`Bool` values can be optional because in `Defaults``Bool` values are
 ///  `nil` or `true` by default. Other standard values must be non-optional to
 ///  be referenced. The goal is to set and remove values without unwrapping.
 unowned let keyPath: ReferenceWritableKeyPath<Settings, Value?>
 unowned let settings: Settings

 public var lastValue: Value!
 public var wrappedValue: Value {
  get { self[dynamicMember: keyPath] }
  nonmutating set {
   guard newValue != lastValue else { return }
   self[dynamicMember: keyPath] = newValue
  }
 }

 public var projectedValue: Binding<Value> {
  Binding<Value>(
   get: { wrappedValue },
   set: { wrappedValue = $0 }
  )
 }

 public subscript(
  dynamicMember keyPath: ReferenceWritableKeyPath<Settings, Value?>
 ) -> Value {
  get {
   guard let value = settings[keyPath: keyPath] else {
    fatalError(
     """
     Couldn't retrieve the value from user defaults. Try subscripting as \
     `[codable:]` or `[codableArray:]` and comforming values to `AutoCodable`.
     """
    )
   }
   return value
  }
  nonmutating set { settings[keyPath: keyPath] = newValue }
 }

 public mutating func update() {
  guard lastValue != wrappedValue else { return }
  self.lastValue = wrappedValue
 }

 public func remove() {
  settings.remove(keyPath)
 }

 public init(
  _ keyPath: ReferenceWritableKeyPath<Settings, Value?>,
  settings: Settings = .default
 ) {
  self.keyPath = keyPath
  self.settings = settings
  self.lastValue = wrappedValue
 }
// public init(
//  wrappedValue: Value,
//  _ keyPath: ReferenceWritableKeyPath<Settings, Value?>,
//  settings: Settings = .default
// ) {
//  if settings[keyPath: keyPath] == nil {
//   settings[keyPath: keyPath] = wrappedValue
//  }
//  self.init(keyPath, settings: settings)
// }
}
