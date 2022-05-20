import protocol Combine.ObservableObject
import struct Combine.Published
import CoreLocation
import class Foundation.NSObject
import MapKit
import Storage
import SwiftUI
import Colors

@available(macOS 11.0, *)
open class MapController:
 CLGeocoder,
 MKMapViewDelegate,
 CLLocationManagerDelegate,
 MKLocalSearchCompleterDelegate,
 StateObservable {
 public static let shared = MapController()
 public var userImage: UIImage?
 public var onAppear: ((MapController) -> ())?
 public var onUpdate: ((MapController) -> ())?
 public var didSetRegion: ((Geohash) -> ())?
 public var onUpdateAnnotation: ((AnyMapIdentifiable) -> Bool)?
 public var annotation: ((AnyMapIdentifiable, SomeAnnotation) -> ())?
 public var marker: ((AnyMapIdentifiable) -> MapMarker?) = { _ in MapMarker() }
 public var overlay: ((AnyMapIdentifiable) -> MapOverlay?)?
 public var view: MKMapView = .init()
 public var manager: CLLocationManager = .init()
 public var completer: MKLocalSearchCompleter = .init()
 /// - Note: Adjusts for insets (camera postion as well)
 public var insets: UIEdgeInsets = .zero
 var xOffset: Double { Double(insets.left + insets.right) }
 var yOffset: Double { Double(insets.top + insets.bottom) }
 var insetRect: MKMapRect {
  view.visibleMapRect.insetBy(dx: xOffset, dy: yOffset)
 }

 @Published
 public var state: PublisherState = .initialize {
  willSet {
   if newValue != state,
      state == .update
      || state == .load
      || state == .unload,
      newValue == .change
      || newValue == .finalize
      || newValue == .unload {
    withAnimation { [weak self] in
     debugPrint("\(Self.self): State transitioned to \(newValue)")
     self?.objectWillChange.send()
    }
   }
  }
 }

 @Published public var values: [AnyMapIdentifiable] = .empty

 @Published public var mode: MKUserTrackingMode = .none {
  willSet {
   if newValue != mode {
    view.userTrackingMode = newValue
    update { $0.updateTracking() }
   }
  }
 }

 @Published public var mapType: MKMapType = .standard {
  willSet {
   if newValue != view.mapType {
    update { controller in
     controller.view.mapType = newValue
    }
   }
  }
 }

 @Published public var position: Position?
 @Published public var reverseLocation: ReverseGeo?
 @Published public var location: CLLocation? {
  didSet {
   guard let location = location else { return }
   if oldValue == nil {
    let coordinate = location.coordinate
    debugPrint(
     "Set Initial Location to \(coordinate.description)."
    )
    self.geohash = Geohash(from: coordinate, with: precision)
    let region =
     MKCoordinateRegion(
      center: coordinate,
      latitudinalMeters: precision.meterRadius,
      longitudinalMeters: precision.meterRadius
     )
    debugPrint(
     "Set Region With Span of \(precision.degrees) degrees."
    )
    self.region = region
    // view.setCameraBoundary(.init(coordinateRegion: region), animated: false)
   }
   if location != oldValue {
    // debugPrint("Updated location to: \(coordinate.description)")
   }
  }
 }

 @Published public var geohash: Geohash? {
  willSet {
   if geohash == nil, let newValue = newValue, let didSetRegion = didSetRegion {
    async(perform: didSetRegion(newValue))
   }
  }
 }

 @Published public var currentMarker: AnyMapIdentifiable? {
  willSet {
   guard let marker = newValue else { return }
   guard let annotation =
    view.annotations.parallelMap({ $0 as? SomeAnnotation })
    .first(where: { $0.id == marker.id })
//     view.annotations.first(
//     where: {
//      guard let value = $0 as? SomeAnnotation else { return false }
//      return value.id == marker.id
//     }
//    )
   else { return }
//   async { `self` in
   let center =
    CLLocationCoordinate2D(
     latitude: marker.coordinate.latitude,
     longitude: marker.coordinate.longitude
    )
   if let location = self.location {
    if self.position == .top { self.position = .center }
    self.view.setCamera(
     MKMapCamera(
      lookingAtCenter: center,
      fromDistance: marker.distance(from: location),
      pitch: self.view.camera.pitch,
      heading: self.view.camera.heading
     ), animated: true
    )
   } else {
    self.view.setCenter(center, animated: true)
   }
   view.selectedAnnotations = [annotation]
  }
 }

 /// Region for completer.
 public var region: MKCoordinateRegion = .init() {
  willSet {
   if !completer.isSearching {
    completer.region = newValue
   }
  }
 }

 /// Precision for completer.
 public var precision: Geohash.Precision = .sixHundredThirtyKilometers
 public var completerQuery: String = .empty {
  didSet {
   guard completerQuery.notEmpty, completerQuery != oldValue else { return }
   update { `self` in
    self.completer.queryFragment = self.completerQuery
   }
  }
 }

 public var lastCompleterResults: [MKLocalSearchCompletion] = .empty
 public lazy var currentLocation: CLLocation? = manager.location

 public func append<A: MapIdentifiable>(_ elements: [A]) {
  for element in elements {
   if let index = self.values.firstIndex(where: { $0.id == element.id }) {
    if let onUpdateAnnotation = onUpdateAnnotation,
       !onUpdateAnnotation(self.values[index]) {
     self.values.remove(at: index)
    } else {
     self.values[index] = element.erased()
    }
   } else {
    self.values.append(element.erased())
   }
  }
  update { controller in controller.updateAnnotations() }
 }

 public func remove<A: MapIdentifiable>(_ elements: A...) {
  for element in elements {
   values.removeAll(where: { $0.id == element.id })
  }
  update { controller in controller.updateAnnotations() }
 }

 public var locationHandler: (CLLocation?) -> () = { _ in }
 public func getLocation<R>(
  _ completion: @escaping (CLLocation?) -> R
 ) -> R {
  completion(manager.location)
 }

 override public init() {
  super.init()
  setupMap()
  setupManager()
  setupCompleter()
 }
}

@available(macOS 11.0, *)
public extension MapController {
 func requestReverseLocation(
  for location: CLLocation?,
  result: @escaping (Result<[CLPlacemark]?, LocationError>) -> ()
 ) {
  if let location = location {
   reverseGeocodeLocation(location) { placemarks, error in
    if let error = error { result(.failure(.error(error))) }
    guard let placemarks = placemarks else { return }
    result(.success(placemarks))
   }
  } else {
   result(.failure(.code(.locationUnknown)))
  }
 }

 func setupMap() {
  view.delegate = self
  view.isRotateEnabled = true
  view.isPitchEnabled = true
  view.showsUserLocation = true
  view.showsCompass = false
  view.isZoomEnabled = true
  view.showsTraffic = true
  #if os(iOS)
   view.showsLargeContentViewer = true
  #endif
 }

 func setupManager() {
  manager.activityType = .fitness
  manager.distanceFilter = 1
  manager.desiredAccuracy = kCLLocationAccuracyBest
  manager.requestWhenInUseAuthorization()
 }

 func setupCompleter() {
  completer.delegate = self
  completer.resultTypes = [.address, .pointOfInterest]
 }

 func updateTracking() {
  if mode != .none {
   defer { manager.startUpdatingLocation() }
   if manager.delegate == nil {
    manager.delegate = self
   }
   #if os(iOS)
    if mode == .followWithHeading {
     manager.startUpdatingHeading()
     view.setUserTrackingMode(.followWithHeading, animated: true)
    } else if mode == .follow {
     manager.stopUpdatingHeading()
     view.setUserTrackingMode(.none, animated: true)
    }
   #endif
  } else {
   manager.stopUpdatingLocation()
   manager.delegate = nil
   location = nil
   view.selectedAnnotations = .empty
  }
 }

 func updateAnnotations() {
  view.removeAnnotations(view.annotations)
  for value in values {
   let newAnnotation = SomeAnnotation(value)
   newAnnotation.coordinate = value.coordinate
   if let annotation = annotation {
    annotation(value, newAnnotation)
   }
   UIView.animate(withDuration: 2.5) { [unowned view] in
    view.addAnnotation(newAnnotation)
   }
  }
 }

 func updateAnnotationsWithTracking() {
  updateAnnotations()
  updateTracking()
 }
}

@available(macOS 11.0, *)
public extension MapController {
 // MARK: Completer Functions
 func completer(_: MKLocalSearchCompleter, didFailWithError error: Error) {
  debugPrint(error.localizedDescription)
  completer.cancel()
 }

 func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
  guard completer.results.notEmpty,
        completer.results != lastCompleterResults
  else { return }
  update { [unowned completer] `self` in
   completer.cancel()
   self.completer.queryFragment = .empty
   self.lastCompleterResults = completer.results
  }
 }

 // MARK: Location Functions
 func locationManager(
  _: CLLocationManager,
  didFailWithError _: Error
 ) {
  mode = .none
 }

 func locationManager(
  _ manager: CLLocationManager,
  didUpdateLocations _: [CLLocation]
 ) {
  if let location = manager.location, location != self.location {
   self.location = location
   if let onUpdate = onUpdate { async(onUpdate) }
  }
 }

 // MARK: - MapView Functions
 func mapViewDidFinishLoadingMap(_: MKMapView) {
  guard let onAppear = onAppear else { return }
  async(onAppear)
 }

 func mapView(_: MKMapView, didDeselect _: MKAnnotationView) {
  currentMarker = nil
 }

// func mapView(
//  _: MKMapView, didChange _: MKUserTrackingMode, animated _: Bool
// ) {
//  update { $0.updateTracking() }
// }

 func mapView(
  _ mapView: MKMapView,
  viewFor annotation: MKAnnotation
 ) -> MKAnnotationView? {
  switch annotation {
  case let annotation where annotation is MKUserLocation:
   guard let marker = mapView.view(for: annotation)
   else { return nil }
   if let image = userImage {
    // marker?.image = image
    if let calloutView = marker.detailCalloutAccessoryView {
     if let imageView =
      calloutView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
      imageView.image = image
     }
    }
   }
   return marker
  case let annotation where annotation is SomeAnnotation:
   guard let annotation = annotation as? SomeAnnotation else { return nil }
   var marker: MKAnnotationView?
   guard let value = annotation.value as? AnyMapIdentifiable
   else { return nil }
   if let wrapper = self.marker(value) {
    switch wrapper.style {
    case let .marker(color):
     marker =
      MKMarkerAnnotationView(
       annotation: annotation,
       reuseIdentifier: annotation.id
      )
     (marker as? MKMarkerAnnotationView)?.markerTintColor =
     NativeColor(color ?? Settings.default.accentColor)
     (marker as? MKMarkerAnnotationView)?.animatesWhenAdded = true
    case let .pin(color):
     marker =
      MKPinAnnotationView(
       annotation: annotation,
       reuseIdentifier: annotation.id
      )
     (marker as? MKPinAnnotationView)?.pinTintColor =
      NativeColor(color ?? .defaultColor)
     (marker as? MKPinAnnotationView)?.animatesDrop = true
    case .none:
     if
      let content = wrapper.content {
      let view = HostingController(rootView: content).view
      #if os(iOS)
       guard let view = view else { return .init() }
      #endif
      marker = MKAnnotationView(
       annotation: annotation,
       reuseIdentifier: annotation.id
      )
      marker?.addSubview(view)
     }
    }
   }
   if let marker = marker,
      let overlay = overlay?(value) {
    marker.canShowCallout = true
    let view = HostingController(rootView: overlay).view
    #if os(iOS)
     guard let view = view else { return .init() }
     view.backgroundColor = .clear
     view.contentMode = .redraw
    #endif
    // TODO: Fix
    async { [unowned marker] _ in
//     if Settings.default.reducedBlur {
//      for view in marker.subviews where view is UIVisualEffectView {
//       view.removeFromSuperview()
//      }
//     }
     marker.detailCalloutAccessoryView = view
     marker.detailCalloutAccessoryView?.setNeedsDisplay()
     marker.detailCalloutAccessoryView?.setNeedsUpdateConstraints()
    }
   }
   return marker
  default: return nil
  }
 }
}

// MARK: - Completion Functions
extension MKLocalSearchCompletion: Identifiable {
 public var id: ObjectIdentifier { ObjectIdentifier(self) }
}

extension MKUserTrackingMode: CaseIterable, Identifiable {
 public static let allCases: [Self] = [.none, .follow, .followWithHeading]
 public var id: Int { rawValue }
}

extension MKMapType: CaseIterable, Identifiable, CustomStringConvertible {
 public static let allCases: [Self] = [.standard, .hybrid, .satellite]
 public var id: UInt { rawValue }
 public var description: String {
  switch self {
  case .standard: return "standard"
  case .hybrid: return "hybrid"
  case .satellite: return "satellite"
  default: fatalError("No description was set for this case.")
  }
 }
}
