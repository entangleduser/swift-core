public protocol Changeable {
 @discardableResult
 func change(_ handler: @escaping (inout Self) -> ()) -> Self
}

public extension Changeable {
 @discardableResult
 func change(_ handler: @escaping (inout Self) -> ()) -> Self {
  var changing = self
  handler(&changing)
  return changing
 }
}
