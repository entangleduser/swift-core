import protocol Core.Infallible
import MapKit

public struct Geohash:
Codable, Hashable, Equatable, ExpressibleByNilLiteral, RawRepresentable {
 public var rawValue: String
 public init?(rawValue: String) {
  self.rawValue = rawValue
 }

 private static let bitmap = "0123456789bcdefghjkmnpqrstuvwxyz".enumerated()
  .map {
   ($1, String(integer: $0, radix: 2, padding: 5))
  }
  .reduce(into: [Character: String]()) {
   $0[$1.0] = $1.1
  }

 private static let charmap = bitmap
  .reduce(into: [String: Character]()) {
   $0[$1.1] = $1.0
  }

 static func decode(hash: String) ->
 (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))? {
  // For example: hash = u4pruydqqvj

  let bits = hash.map { bitmap[$0] ?? "?" }.joined(separator: "")
  guard bits.count % 5 == 0 else { return nil }
  // bits = 1101000100101011011111010111100110010110101101101110001

  let (lat, lon) = bits.enumerated()
   .reduce(into: ([Character](), [Character]())) {
    if $1.0 % 2 == 0 { $0.1.append($1.1) }
    else { $0.0.append($1.1) }
   }
  // lat = [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0]
  // lon = [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1]

  func combiner(
   array a: (min: Double, max: Double),
   value: Character
  ) -> (Double, Double) {
   let mean = (a.min + a.max) / 2
   return value == "1" ? (mean, a.max) : (a.min, mean)
  }
  let latRange = lat.reduce((-90.0, 90.0), combiner)
  // latRange = (57.649109959602356, 57.649111300706863)
  let lonRange = lon.reduce((-180.0, 180.0), combiner)
  // lonRange = (10.407439023256302, 10.407440364360809)
  return (latRange, lonRange)
 }

 static func encode(
  latitude: Double, longitude: Double, length: Int
 ) -> String {
  // For example: (latitude, longitude) = (57.6491106301546, 10.4074396938086)

  func combiner(
   array a: (min: Double, max: Double, array: [String]),
   value: Double
  ) -> (Double, Double, [String]) {
   let mean = (a.min + a.max) / 2
   if value < mean {
    return (a.min, mean, a.array + "0")
   } else {
    return (mean, a.max, a.array + "1")
   }
  }

  let lat = Array(
   repeating: latitude, count: length * 5
  )
  .reduce((-90.0, 90.0, [String]()), combiner)
  // lat = (57.64911063015461, 57.649110630154766, [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,0,...])

  let lon = Array(
   repeating: longitude, count: length * 5
  )
  .reduce((-180.0, 180.0, [String]()), combiner)
  // lon = (10.407439693808236, 10.407439693808556, [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1,0,1,..])

  let latlon = lon.2.enumerated().flatMap { [$1, lat.2[$0]] }
  // latlon - [1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,...]

  let bits =
   latlon.enumerated().reduce([String]()) {
    $1.0 % 5 > 0 ? $0 << $1.1 : $0 + $1.1
   }
  //  bits: [11010,00100,10101,10111,11010,11110,01100,10110,10110,11011,10001,10010
  // ,10101,...]

  let arr = bits.compactMap { charmap[$0] }
  // arr: [u,4,p,r,u,y,d,q,q,v,j,k,p,b,...]

  return String(arr.prefix(length))
 }
}

public extension Geohash {
 init(
  from coordinate: CLLocationCoordinate2D,
  with precision: Precision = .defaultValue
 ) {
  self.init(
   rawValue:
   Self.encode(
    latitude: coordinate.latitude,
    longitude: coordinate.longitude,
    precision: precision
   )
  )!
 }

 init(nilLiteral _: ()) {
  self.init(from: .init())
 }
}

public extension Geohash {
 enum Precision: Int, Infallible, CustomStringConvertible {
  case twentyFiveHundredKilometers = 1, // ±2500 km
       sixHundredThirtyKilometers, // ±630 km
       seventyEightKilometers, // ±78 km
       twentyKilometers, // ±20 km
       twentyFourHundredMeters, // ±2.4 km
       sixHundredTenMeters, // ±0.61 km
       seventySixMeters, // ±0.076 km
       nineteenMeters, // ±0.019 km
       twoHundredFourtyCentimeters, // ±0.0024 km
       sixtyCentimeters, // ±0.00060 km
       seventyFourMillimeters // ±0.000074 km
  
  public var description: String {
   switch self {
   case .sixHundredThirtyKilometers: return "391 miles"
   default: fatalError("No decription was set for this case!")
   }
  }

  public var kilometerRadius: Double {
   switch self {
   case .twentyFiveHundredKilometers: return 2500
   case .sixHundredThirtyKilometers: return 630
   case .seventyEightKilometers: return 78
   case .twentyKilometers: return 20
   case .twentyFourHundredMeters: return 2.4
   case .sixHundredTenMeters: return 0.61
   case .seventySixMeters: return 0.076
   case .nineteenMeters: return 0.019
   case .twoHundredFourtyCentimeters: return 0.0024
   case .sixtyCentimeters: return 0.00060
   case .seventyFourMillimeters: return 0.000074
   }
  }

  public var meterRadius: Double { kilometerRadius * 1000 }
  public var degrees: Double { kilometerRadius * 0.008 }
  public static var defaultValue: Self { sixHundredThirtyKilometers }
 }

 static func encode(
  latitude: Double, longitude: Double, precision: Precision
 ) -> String {
  encode(latitude: latitude, longitude: longitude, length: precision.rawValue)
 }
}

private extension String {
 init(integer n: Int, radix: Int, padding: Int) {
  let s = String(n, radix: radix)
  let pad = (padding - s.count % padding) % padding
  self = Array(repeating: "0", count: pad).joined(separator: "") + s
 }
}

private func + (left: [String], right: String) -> [String] {
 var arr = left
 arr.append(right)
 return arr
}

private func << (left: [String], right: String) -> [String] {
 var arr = left
 var s = arr.popLast()!
 s += right
 arr.append(s)
 return arr
}

public extension CLLocationCoordinate2D {
 init(geohash: String) {
  if let (lat, lon) = Geohash.decode(hash: geohash) {
   self =
    CLLocationCoordinate2DMake(
     (lat.min + lat.max) / 2, (lon.min + lon.max) / 2
    )
  } else {
   self = kCLLocationCoordinate2DInvalid
  }
 }

 func geohash(length: Int) -> String {
  Geohash.encode(latitude: latitude, longitude: longitude, length: length)
 }

 func geohash(precision: Geohash.Precision = .defaultValue) -> String {
  geohash(length: precision.rawValue)
 }
}
