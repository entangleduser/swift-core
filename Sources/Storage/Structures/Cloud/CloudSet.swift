import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public extension Cloud {
  @propertyWrapper
  struct Set: StorageWrapper {
    public let path: KeyPath<Value.Container, [Value]>
    public var defaultValue: [Value]?
    public var wrappedValue: [Value] {
      get {
        let value = Value.Container.shared[of: Value.self]
        return value.isEmpty ? (defaultValue ?? value) : value
      }
      nonmutating set {
        Value.Container.shared[of: Value.self] = newValue
      }
    }

		@available(macOS 10.15, iOS 13.0, *)
    public var projectedValue: Binding<[Value]> {
      Binding<[Value]>(
        get: { wrappedValue },
        set: { Value.Container.shared[of: Value.self] = $0 }
      )
    }

    public init(
      wrappedValue: [Value] = [],
      _ path: KeyPath<Value.Container, [Value]>
    ) {
      self.path = path
      if wrappedValue.isEmpty {
        defaultValue = wrappedValue
      }
    }
  }
}
