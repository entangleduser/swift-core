import CoreData

// public struct CloudKey<Value>: Hashable
//  where Value: CloudEntity {
//  public init() {}
// }
@available(macOS 10.15, iOS 13.0, *)
public protocol CloudKey {
 associatedtype Value: CloudEntity
 // static var defaultValue: Value { get }
}
