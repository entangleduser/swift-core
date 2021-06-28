@available(macOS 10.15, iOS 13.0, *)
public protocol CloudContainer: StateObservable {
  subscript<T>(of set: T.Type) -> [T]
    where T: CloudEntity { get set }
  subscript<T>(_: T.Type) -> T?
    where T: CloudEntity { get set }
  static var shared: Self { get }
}

@available(macOS 10.15, iOS 13.0, *)
public extension CloudContainer {
//  subscript<T>(of set: T.Type) -> [T]
//    where T: CloudEntity {
//    get { Self[of: T.Value.self] }
//    set { Self[of: T.Value.self] = newValue }
//  }
//  subscript<T>(_: T.Type) -> T.Value?
//    where T: CloudEntity {
//    get { Self[T.Value.self] }
//    set { Self[T.Value.self] = newValue }
//  }
}
