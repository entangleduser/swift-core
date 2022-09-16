import class MapKit.MKPointAnnotation

open class SomeAnnotation: MKPointAnnotation {
 public let id: String
 public let value: Any
 public init<Value>(_ value: Value) where Value: MapIdentifiable {
  self.value = value
  id = value.id
  super.init()
  coordinate = value.coordinate
 }

 //	init(_ value: AnyMapIdentifiable) {
 //		self.value = value.value
 //		id = value.id
 //		super.init()
 //		coordinate = value.coordinate
 //	}
}
