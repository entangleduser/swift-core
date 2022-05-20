import CoreLocation
import MapKit
import SwiftUI
import Storage

@available(macOS 11.0, *)
public struct MapView: ViewRepresentable {
 @Binding public var mode: MKUserTrackingMode
 @Binding public var type: MKMapType
 public var userImage: UIImage?
 public var insets: NativeEdgeInsets
 public var onAppear: ((MapController) -> ())?
 public var onUpdate: ((MapController) -> ())?
 public var onUpdateAnnotation: ((AnyMapIdentifiable) -> Bool)?
 public var annotation: ((AnyMapIdentifiable, SomeAnnotation) -> ())?
 public var marker: ((AnyMapIdentifiable) -> MapMarker?)?
 public var overlay: ((AnyMapIdentifiable) -> MapOverlay?)?
 public func makeCoordinator() -> MapController { .shared }
 public func makeView(context: Context) -> MKMapView {
  context.coordinator.update(
   context.coordinator.state == .initialize ? .finalize : .update
  ) { controller in
   controller.userImage = userImage
   controller.insets = insets
   if let onAppear = onAppear {
    controller.onAppear = onAppear
   }
   if let onUpdate = onUpdate {
    controller.onUpdate = onUpdate
   }
   controller.annotation = self.annotation
   if let marker = self.marker {
    controller.marker = marker
   }
   if let onUpdateAnnotation = onUpdateAnnotation {
    controller.onUpdateAnnotation = onUpdateAnnotation
   }
   if let overlay = self.overlay {
    controller.overlay = overlay
   }
   controller.mode = self.mode
   controller.mapType = self.type
  }
  return context.coordinator.view
 }

 public func updateView(_: MKMapView, context _: Context) {}

 #if os(iOS)
  public func makeUIView(context: Context) -> MKMapView {
   makeView(context: context)
  }

  public func updateUIView(_ mapView: MKMapView, context: Context) {
   updateView(mapView, context: context)
  }

 #elseif os(macOS)
  public func makeNSView(context: Context) -> MKMapView {
   makeView(context: context)
  }

  public func updateNSView(_ mapView: MKMapView, context: Context) {
   updateView(mapView, context: context)
  }
 #endif

 public init(
  mode: Binding<MKUserTrackingMode> = .constant(.followWithHeading),
  type: Binding<MKMapType> = .constant(.standard),
  userImage: UIImage? = .none,
  insets: NativeEdgeInsets = .zero,
  onAppear: ((MapController) -> ())? = nil,
  onUpdate: ((MapController) -> ())? = nil,
  onUpdateAnnotation: ((AnyMapIdentifiable) -> Bool)? = nil,
  annotation: ((AnyMapIdentifiable, SomeAnnotation) -> ())? = nil,
  marker: ((AnyMapIdentifiable) -> MapMarker?)? = nil,
  @ViewBuilder overlay: @escaping (AnyMapIdentifiable) -> MapOverlay?
 ) {
  _mode = mode
  _type = type
  self.userImage = userImage
  self.insets = insets
  self.onAppear = onAppear
  self.onUpdate = onUpdate
  self.annotation = annotation
  self.onUpdateAnnotation = onUpdateAnnotation
  self.marker = marker
  self.overlay = overlay
 }
}

// MARK: Associated Views
public struct MapMarker {
 public init(
  action: (() -> ())? = nil,
  content: AnyView? = nil,
  style: MapMarker.Style? = .marker(nil)
 ) {
  self.action = action
  self.content = content
  self.style = style
 }

 public var action: (() -> ())?
 public var content: AnyView?
 public var style: Style? = .marker(nil)
}

public extension MapMarker {
 enum Style {
  case marker(Color?), pin(Color?)
 }

 init<V>(
  action: (() -> ())? = .none,
  content: (() -> V)?,
  style _: MapMarker.Style? = .marker(nil)
 ) where V: View {
  if let action = action {
   self.action = action
  }
  if let content = content {
   self.content = AnyView(content())
  }
 }
}

public struct MapOverlay: View {
 var action: (() -> ())?
 let label: AnyView

 public var body: some View {
  label
   .frame(height: 80, alignment: .leading)
   .frame(maxWidth: .screen.width)
   .padding(.vertical, 4.5)
   .minimumScaleFactor(0.75)
   .contentShape(Rectangle())
   .onTapGesture {
    DispatchQueue.main.async {
     action?()
    }
   }
 }

 public init<V>(action: (() -> ())? = .none, @ViewBuilder label: () -> V)
  where V: View {
  self.label = AnyView(label())
  self.action = action
 }
}

// TODO: Add typing to auxillary map views.
// public struct MapOverlay<A: MapIdentifiable, B: View>: View {
// let value: A
// var action: ((A) -> ())?
// let label: (A) -> B
// public var body: some View {
//  label(value)
//   .frame(height: 80, alignment: .leading)
//   .frame(maxWidth: .screen.width / 1.5)
//   .padding(.vertical, 4.5)
//   .offset(y: -15)
//   .minimumScaleFactor(0.75)
//   .contentShape(Rectangle())
//   .onTapGesture {
//    DispatchQueue.main.async {
//     action?(value)
//    }
//   }
// }
//
// public init(
//  value: A, action: ((A) -> ())? = .none, @ViewBuilder label: @escaping (A) -> B
// ) {
//  self.value = value
//  self.label = label
//  self.action = action
// }
// }

@available(macOS 11.0, *)
public struct ReverseLocationView<A: MapIdentifiable, Content: View>: View {
 @ObservedObject var map: MapController = .shared
 let location: A
 @ViewBuilder var content: (ReverseGeo?) -> Content
 public var body: some View {
  content(
   ReverseGeo.Storage[location.id] ?? (
    (map.reverseLocation?.id ?? .empty) == location.id ?
     map.reverseLocation : .none)
  )
  .onAppear { [unowned map] in
   guard ReverseGeo.Storage[location.id] != nil else {
    map.requestReverseLocation(
     for: location.coreLocation,
     result: { result in
      switch result {
      case let .success(values):
       if let placemark: CLPlacemark = values?.first,
          let state = placemark.administrativeArea {
        let reverse =
         ReverseGeo(
          id: location.id,
          stateCode:
          States.allCases.first { $0.abbreviation == state },
          city: placemark.locality,
          zip: placemark.postalCode,
          address: placemark.thoroughfare
         )
        ReverseGeo.Storage[location.id] = reverse
        map.reverseLocation = reverse
       }
      case let .failure(error): debugPrint(error.localizedDescription)
      }
     }
    )
    map.reverseLocation = .none
    return
   }
  }
 }

 public init(
  _ location: A,
  @ViewBuilder content: @escaping (ReverseGeo?) -> Content
 ) {
  self.location = location
  self.content = content
 }
}

public struct CompassButton: ViewRepresentable {
 @ObservedObject var settings: Settings = .default
 private let button: MKCompassButton
 public init?(mapView: MKMapView, visibility: MKFeatureVisibility = .visible) {
  mapView.showsCompass = false
  button = .init(mapView: mapView)
  button.compassVisibility = visibility
  guard settings.showCompass else { return nil }
 }

 public func makeView(context _: Context) -> MKCompassButton {
//  button.backgroundColor = .clear
//  button.layer.backgroundColor = Color.clear.cgColor
//  button.layer.sublayers?.forEach {
//   //$0.backgroundColor = Color.clear.cgColor
//   $0.removeFromSuperlayer()
//  }
  return button
 }

 public func updateView(_: MKCompassButton, context _: Context) {}
 #if os(iOS)
  public func makeUIView(context: Context) -> MKCompassButton {
   makeView(context: context)
  }

  public func updateUIView(_ mapView: MKCompassButton, context: Context) {
   updateView(mapView, context: context)
  }

 #elseif os(macOS)
  public func makeNSView(context: Context) -> MKCompassButton {
   makeView(context: context)
  }

  public func updateNSView(_ mapView: MKCompassButton, context: Context) {
   updateView(mapView, context: context)
  }
 #endif
}
