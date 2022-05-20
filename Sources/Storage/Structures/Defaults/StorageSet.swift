import SwiftUI

public extension Storage {
 @propertyWrapper
 struct Set: DefaultsWrapper {
  public var store: UserDefaults = .standard
  public let key: String

  public var wrappedValue: [Storage.Value] {
   get { store.array(forKey: key) as? [Storage.Value] ?? [] }
   nonmutating set { store.set(newValue, forKey: key) }
  }

  @available(macOS 10.15, iOS 13.0, *)
  public var projectedValue: Binding<[Storage.Value]> {
   Binding<[Storage.Value]>(
    get: { self.wrappedValue },
    set: { self.wrappedValue = $0 }
   )
  }

  public init(
   wrappedValue: [Storage.Value] = [],
   _ key: String, store: UserDefaults? = nil
  ) {
   self.key = key
   if let store = store { self.store = store }
   if self.store.object(forKey: key) == nil {
    self.wrappedValue = wrappedValue
   }
  }
 }
}
