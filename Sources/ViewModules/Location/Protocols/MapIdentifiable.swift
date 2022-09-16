import MapKit

@_typeEraser(AnyMapIdentifiable)
public protocol MapIdentifiable: Identifiable, Equatable
where ID == String {
 var coordinate: CLLocationCoordinate2D { get }
}

public extension MapIdentifiable {
 func hash(into hasher: inout Hasher) {
  hasher.combine(id)
 }

 func erased() -> AnyMapIdentifiable {
  AnyMapIdentifiable(erasing: self)
 }

 var coreLocation: CLLocation {
  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
 }

 func openInMaps() {
  MKMapItem(
   placemark:
   MKPlacemark(coordinate: coordinate)
  ).openInMaps()
 }

 /// Distance between two objects in meters.
 func distance<T>(from point: T) -> Double where T: MapIdentifiable {
  coreLocation.distance(from: point.coreLocation)
 }

 @_transparent
 static func - <T>(lhs: Self, rhs: T) -> Double where T: MapIdentifiable {
  lhs.distance(from: rhs)
 }
}

extension CLLocation: MapIdentifiable {
 public var id: String { String(ObjectIdentifier(self).hashValue) }
}
