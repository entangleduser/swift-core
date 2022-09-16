import Combine

//public protocol SettingsWrapper {
// associatedtype Key: SettingsKey
// var settings: Settings { get }
// subscript(_: Key) -> Key.Value { get nonmutating set }
//}
//
//public extension SettingsWrapper {
// func clear() {
//  settings.defaults.removeObject(forKey: Key().description)
// }
//
// subscript(_ key: Key) -> Key.Value {
//  get { settings.get(for: key) }
//  nonmutating set { settings.set(newValue, for: key) }
// }
//}
//
