import SwiftUI

open class SettingsBase: NSObject {
 @objc open dynamic var defaults: UserDefaults { .standard }
 @objc open dynamic var ommitedKeys: [String] { .empty }
 @objc open dynamic func didReset() {}
 @objc public override init() { super.init() }
}

@available(macOS 10.15, iOS 13.0, *)
open class Settings: SettingsBase, StateObservable {
 @Published
 open var state: PublisherState = .initialize {
  willSet {
   if newValue != state,
      state == .update
       || state == .load
       || state == .unload,
      newValue == .change
       || newValue == .finalize
       || newValue == .unload {
    debugPrint("\(Self.self): State transitioned to \(newValue)")
    switch newValue {
    case .reset: reset()
    default: break
    }
    self.objectWillChange.send()
   }
  }
 }

 open func reset(excluding keys: [String] = .empty) {
  let keys = keys + ommitedKeys
  for key in defaults.dictionaryRepresentation().keys
   where !keys.contains(key) {
   defaults.removeObject(forKey: key)
  }
  didReset()
 }

 open func remove<Key: SettingsKey>(_ key: Key) {
  if defaults.dictionaryRepresentation().keys.contains(key.description) {
   debugPrint("Removing settings key: \(key.description)")
   defaults.removeObject(forKey: Key().description)
  }
 }

 open func remove<Value>(_ keyPath: ReferenceWritableKeyPath<Settings, Value?>) {
  update { settings in
   settings[keyPath: keyPath] = .none
  }
 }

 open subscript<Key: SettingsKey>(_: Key.Type) -> Key.Value! {
  get { get(for: Key()) }
  set { update { `self` in self.set(newValue, for: Key()) } }
 }

 open subscript<Key: SettingsKey>(codable _: Key.Type) -> Key.Value!
  where Key.Value: AutoCodable {
  get { getCodable(for: Key()) }
  set { update { `self` in self.setCodable(newValue, for: Key()) } }
 }

// open subscript<Key: SettingsKey>(array _: Key.Type) -> [Key.Value]!
//  where Key.Value: AutoCodable {
//  get { getCodableArray(for: Key()) }
//  set { update { `self` in self.setCodableArray(newValue, for: Key()) } }
// }
// public required override init() { super.init() }
}

@available(macOS 10.15, iOS 13.0, *)
public extension Settings {
 static let `default` = Settings()
 func get<Key: SettingsKey>(for key: Key) -> Key.Value {
  return
   defaults.value(forKey: key.description) as? Key.Value ?? Key.defaultValue
 }

 func set<Key: SettingsKey>(_ value: Key.Value?, for key: Key) {
  guard let value = value else {
   remove(key)
   return
  }
  defaults.setValue(value, forKey: key.description)
 }

 func getCodable<Key: SettingsKey>(for key: Key) -> Key.Value
 where Key.Value: AutoCodable {
  if let data =
   (defaults.value(forKey: key.description) as? Key.Value.AutoDecoder.Input),
   let value = try? Key.Value.decoder
    .decode(Key.Value.self, from: data) {
   return value
  }
  return Key.defaultValue
 }

 func setCodable<Key: SettingsKey>(_ value: Key.Value?, for key: Key)
 where Key.Value: AutoCodable {
  guard let value = value else {
   remove(key)
   return
  }
  try? defaults.setValue(value.encoded(), forKey: key.description)
 }

// func getCodableArray<Key: SettingsKey>(for key: Key) -> [Key.Value]
// where Key.Value: AutoCodable {
//  if let data =
//   (defaults.value(forKey: key.description) as? [Key.Value.AutoDecoder.Input]),
//   let value = try? Key.Value.decoder
//      .decode(Key.Value.self, from: data) {
//   return value
//  }
//  return .empty
// }

// func setCodableArray<Key: SettingsKey>(_ value: [Key.Value]?, for key: Key)
// where Key.Value: AutoCodable {
//  guard let value = value else {
//   remove(key)
//   return
//  }
//  try? defaults.setValue(value.map { try $0.encoded() }, forKey: key.description)
// }
}
