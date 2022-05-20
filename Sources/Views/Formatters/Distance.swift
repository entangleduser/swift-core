import MapKit
import SwiftUI
import Storage

public final class Distance {
 public static let shared = Distance()
 private lazy var map: MapController = .shared
 public let formatter: LengthFormatter = {
  let lengthFormatter = LengthFormatter()
  lengthFormatter.unitStyle = .long
  lengthFormatter.numberFormatter.allowsFloats = false
  lengthFormatter.numberFormatter.maximumFractionDigits = 1
  return lengthFormatter
 }()

 public func from<A, B>(_ start: A? = .none, _ point: B?) -> String
 where A: MapIdentifiable, B: MapIdentifiable {
  guard let start = start, let point = point else { return " ... " }
  return formatter.string(fromMeters: start - point)
 }
}

public extension Distance {
 // TODO: Implement `TimelineView`
 struct Label<Point>: View where Point: MapIdentifiable {
  @Setting(\.showDistance) var showDistance
  @Environment(\.distance) var distance
  @ObservedObject var settings: Settings = .default
  @ObservedObject var map: MapController = .shared
  private let point: Point
  public init?(point: Point) {
   self.point = point
   guard showDistance else { return nil }
  }

  public var body: some View {
//   #if DEBUG
//   Text(point.coordinate.description)
//   #else
    Text(distance.from(map.location, point) + " away")
     .transition(.scale)
//   #endif
  }
 }
}

public extension EnvironmentValues {
 var distance: Distance { Distance.shared }
}

extension CLLocationCoordinate2D: CustomStringConvertible {
 public var description: String {
  "\(longitude.rounded().description) ºN, \(latitude.rounded().description) ºW"
 }
}
