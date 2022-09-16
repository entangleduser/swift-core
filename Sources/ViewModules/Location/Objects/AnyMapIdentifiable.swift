import struct CoreLocation.CLLocationCoordinate2D

public struct AnyMapIdentifiable: MapIdentifiable {
 public let type: Any.Type
 public let id: String
 public let coordinate: CLLocationCoordinate2D
 public let value: Any
 public init<T: MapIdentifiable>(erasing previous: T) {
  type = T.self
  id = previous.id
  coordinate = previous.coordinate
  value = previous
 }

 public static func == (
  lhs: AnyMapIdentifiable,
  rhs: AnyMapIdentifiable
 ) -> Bool {
  lhs.id == rhs.id
 }
}
