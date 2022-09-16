import MapKit

open class UserAnnotation: MKUserLocation {
 public var position: CLLocation? = .none
 override open var location: CLLocation? {
  position
 }
}

public extension UserAnnotation {
 convenience init(location: CLLocation?) {
  self.init()
  position = location
 }
}
