import CoreGraphics

public protocol ColorCodable:
 Codable,
 Hashable,
 ExpressibleByStringLiteral // ,
// ExpressibleByArrayLiteral
{
 var red: Double { get }
 var green: Double { get }
 var blue: Double { get }
 var alpha: Double { get }
 var hue: Double { get }
 var saturation: Double { get }
 var brightness: Double { get }
 var hex: String { get }
 var components: [Double] { get }
 var rgbComponents: [Double] { get }
 var hsbComponents: [Double] { get }
 var hslComponents: [Double] { get }
 var webComponents: [Int] { get }
 var hexComponents: [String] { get }
 init(
  red: Double,
  green: Double,
  blue: Double,
  alpha: Double
 )
}

enum ColorCodingKeys: CodingKey {
 case red, blue, green, alpha
}

infix operator ~: MultiplicationPrecedence
public extension ColorCodable {
 typealias RGBComponents = (
  red: Double?,
  green: Double?,
  blue: Double?,
  alpha: Double?
 )

 var red: Double { components[0] }
 var green: Double { components[1] }
 var blue: Double { components[2] }
 var alpha: Double { components[3] }
 var hue: Double { hsbComponents[0] }
 var saturation: Double { hsbComponents[1] }
 var brightness: Double { hsbComponents[2] }
 var luminosity: Double { hslComponents[2] }
 var hex: String { hexComponents.joined() }
 var rgbComponents: [Double] { [red, green, blue] }

 static func == <C: ColorCodable>(lhs: Self, rhs: C) -> Bool {
  lhs.red == rhs.red
   && lhs.blue == rhs.blue
   && lhs.green == rhs.green
   && lhs.alpha == rhs.alpha
 }

 init(from decoder: Decoder) throws {
  let container = try decoder.container(keyedBy: ColorCodingKeys.self)
  let red = try container.decode(Double.self, forKey: .red)
  let green = try container.decode(Double.self, forKey: .green)
  let blue = try container.decode(Double.self, forKey: .blue)
  let alpha = try container.decode(Double.self, forKey: .alpha)
  self.init(red: red, green: green, blue: blue, alpha: alpha)
 }

 func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: ColorCodingKeys.self)
  try container.encode(red, forKey: .red)
  try container.encode(green, forKey: .green)
  try container.encode(blue, forKey: .blue)
  try container.encode(alpha, forKey: .alpha)
 }

 func compare<C: ColorCodable>(
  _ new: C,
  _ comparison:
  @escaping (_ lhs: Double, _ rhs: Double) -> Double
 ) -> [Double] {
  components.map { lhs -> Double in
   var comp: Double!
   new.components.forEach { rhs in comp = comparison(lhs, rhs) }
   return comp
  }
 }

 func blendColor<C: ColorCodable>(
  _ color: C,
  _ midpoint: Double = 0.5
 ) -> Self {
  Self(fromComponents:
   compare(color) { lhs, rhs -> Double in (1 - midpoint) *
    pow(lhs, 2) + (midpoint * pow(rhs, 2))
   } + [(1 - midpoint) * alpha + (midpoint * color.alpha)]
  )
 }

 static func + <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
  Self(fromComponents:
   lhs.compare(rhs) { lhs, rhs -> Double in
    (lhs + rhs) / 2
   } + [(lhs.alpha + rhs.alpha) / 2]
  )
 }

 static func - <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
  Self(fromComponents:
   lhs.compare(rhs) { lhs, rhs -> Double in min(lhs + rhs, 1) } +
    [min(lhs.alpha + rhs.alpha, 1)]
  )
 }

 static func * <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
  lhs.blendColor(rhs)
 }

 static func / <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
  lhs.blendColor(rhs.inverted)
 }

 init(white: Double, alpha: Double = 1) {
  self.init(red: white, green: white, blue: white, alpha: alpha)
 }

 init(stringLiteral value: StaticString) { self.init(hex: value.description)! }

// init(arrayLiteral elements: Double...) { self.init(fromComponents: elements) }

 @_disfavoredOverload
 init(
  red: Double = 0,
  green: Double = 0,
  blue: Double = 0,
  alpha: Double = 0
 ) {
  self.init(red: red, green: green, blue: blue, alpha: alpha)
 }

 init(red: Int, green: Int, blue: Int, alpha: Double = 1) {
  self.init(
   red: red.fromWeb,
   green: green.fromWeb,
   blue: blue.fromWeb,
   alpha: alpha
  )
 }

 init(
  hue: Double = 0,
  saturation: Double = 0,
  brightness: Double,
  alpha: Double = 1
 ) {
  var r = brightness.squeezed,
      g = brightness.squeezed,
      b = brightness.squeezed,
      h = hue.squeezed,
      s = saturation.squeezed,
      v = brightness.squeezed,
      i = floor(h * 6),
      f = h * 6 - i,
      p = v * (1 - s),
      q = v * (1 - f * s),
      t = v * (1 - (1 - f) * s)
  switch i.truncatingRemainder(dividingBy: 6) {
   case 0: r = v; g = t; b = p
   case 1: r = q; g = v; b = p
   case 2: r = p; g = v; b = t
   case 3: r = p; g = q; b = v
   case 4: r = t; g = p; b = v
   case 5: r = v; g = p; b = q
   default: break
  }
  self.init(red: r, green: g, blue: b, alpha: alpha)
 }

 // https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
 init(
  hue: Double = 0,
  saturation: Double = 0,
  luminosity: Double,
  alpha: Double = 1
 ) {
  let h = hue,
      s = saturation,
      l = luminosity
  var r: Double = 0,
      g: Double = 0,
      b: Double = 0
  if s == 0 {
   r = l
   g = l
   b = l
  } else {
   func hue2rgb(
    _ p: Double,
    _ q: Double,
    _ t: Double
   ) -> Double {
    let t = t.squeezed
    switch t {
     case 0 ... (1 / 6): return p + (q - p) * 6 * t
     case 0 ... (1 / 2): return q
     case 0 ... (2 / 3): return p + (q - p) * (2 / 3 - t) * 6
     default: return p
    }
   }
   let q = l < 0.5 ? l * (1 + s) : l + s - l * s
   let p = 2 * l - q
   r = hue2rgb(p, q, h + 1 / 3 - 0.0000000000000003).squeezed
   g = (hue2rgb(p, q, h) + 0.0000000000000003).squeezed
   b = hue2rgb(p, q, h - 1 / 3 + 0.0000000000000003).squeezed
  }
  self.init(
   red: r.rounded,
   green: g.rounded,
   blue: b.rounded,
   alpha: alpha.rounded
  )
 }

 static func white(
  _ value: Double,
  withAlpha alpha: Double = 1
 ) -> Self {
  Self(red: value, green: value, blue: value, alpha: alpha)
 }

 init?(hex: String, alpha: Double = 1) {
  var hexValue = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
  if hexValue.count == 3 {
   for (index, char) in hexValue.enumerated() {
    hexValue.insert(
     char,
     at: hexValue.index(hexValue.startIndex, offsetBy: index * 2)
    )
   }
  }
  guard hexValue.count == 6,
        let intCode = Int(hexValue, radix: 16) else { return nil }
  self.init(red: (intCode >> 16) & 0xFF,
            green: (intCode >> 8) & 0xFF,
            blue: intCode & 0xFF,
            alpha: alpha)
 }

 @_disfavoredOverload init(fromComponents components: [Double]) {
  self.init(
   red: components[0],
   green: components[1],
   blue: components[2],
   alpha: components.count > 3 ? components[3] : 1
  )
 }

 init(fromComponents components: RGBComponents) {
  self.init(
   red: components.red ?? 0,
   green: components.green ?? 0,
   blue: components.blue ?? 0,
   alpha: components.alpha ?? 1
  )
 }

 var hslComponents: [Double] {
  let r = red, g = green, b = blue
  let maximum = max(r, g, b),
      minimum = min(r, g, b),
      avg = (maximum + minimum) / 2
  var h: Double = avg,
      s: Double = avg,
      l: Double = avg

  if minimum != maximum {
   let d = maximum - minimum
   s = l > 0.5 ?
    d / (2 - maximum - minimum) :
    d / (maximum + minimum)
   switch maximum {
    case r:
     h = (g - b) / d + (g < b ? 6 : 0)
    case g:
     h = (b - r) / d + 2
    case b:
     h = (r - g) / d + 4
    default: break
   }
   h /= 6
  } else {
   h = 0; s = 0
  }
  return [h, s, l, alpha]
 }

 var webComponents: [Int] {
  rgbComponents.map(\.toWeb)
 }

 var hexComponents: [String] {
  webComponents.map {
   String(format: "%2X", $0).replacingOccurrences(of: " ", with: "0")
  }
 }

 func alpha(_ value: Double) -> Self {
  Self(
   red: red,
   green: green,
   blue: blue,
   alpha: alpha * value
  )
 }

 func transform(_ value: @escaping (Double) -> Double) -> Self {
  Self(
   red: value(red).squeezed,
   green: value(green).squeezed,
   blue: value(blue).squeezed,
   alpha: alpha
  )
 }

 var inverted: Self {
  transform { 1 - $0 }
 }

 func withHue(_ value: Double) -> Self {
  Self(
   hue: value,
   saturation: saturation,
   brightness: brightness,
   alpha: alpha
  )
 }

 func withSaturation(_ value: Double) -> Self {
  Self(
   hue: hue,
   saturation: value,
   brightness: brightness,
   alpha: alpha
  )
 }

 func withBrightness(_ value: Double) -> Self {
  Self(
   hue: hue,
   saturation: saturation,
   brightness: value,
   alpha: alpha
  )
 }

 func luminosity(_ value: Double) -> Self {
  Self(hue: hue, saturation: saturation, luminosity: value, alpha: alpha)
 }

 /// (0-1)
 func brighten(_ value: Double) -> Self {
  withBrightness(brightness / (1 + value.clamp(0, 1))).alpha(alpha)
 }

 /// (0-1)
 func darken(_ value: Double) -> Self {
  withBrightness(brightness * (0 + value.clamp(0, 1))).alpha(alpha)
 }

 var lightenedToAlpha: Self {
  guard alpha < 1 else { return self }
  return brighten(alpha)
 }

 var darkenedToAlpha: Self {
  guard alpha < 1 else { return self }
  return darken(alpha)
 }

 var computedBrightness: Double {
  return (red + green + blue + alpha) / 4
 }

 var isDark: Bool { luminosity < 0.55 }
 var isLight: Bool { !isDark }

 func isVisible<C: ColorCodable>(with background: C) -> Bool {
  guard isTransparent else {
   let ratio = luminosity / background.luminosity
   return ratio > 2
  }
  return (
   (red + green + blue - alpha) + (
    background.red + background.green + background.blue
   )
  ) / 2 > 1
 }

 var isOpaque: Bool { alpha == 1 }

 var isTransparent: Bool { !isOpaque }

 var opaque: Self {
  guard isTransparent else { return self }
  return alpha(1)
 }

 func darkBlend<A: ColorCodable>(_ color: A) -> Self {
  (darken(0.15) + color).withSaturation(0.75)
 }

 var shadow: Self { luminosity(0.5) }
 var highlight: Self { luminosity(0.9) }

 static func ?? <A: ColorCodable>(lhs: A?, rhs: Self) -> A { A(lhs ?? A(rhs)) }

 // Generic Colors
 @_transparent @_disfavoredOverload
 static var clear: Self { Self() }
 @_transparent @_disfavoredOverload
 static var black: Self { Self(alpha: 1) }
 @_transparent @_disfavoredOverload
 static var white: Self { Self(white: 1) }
 @_transparent @_disfavoredOverload
 static var red: Self { Self(red: 1) }
 @_transparent @_disfavoredOverload
 static var green: Self { Self(green: 1) }
 @_transparent @_disfavoredOverload
 static var blue: Self { Self(blue: 1) }
 // Special Colors
 @_transparent
 static var graphite: Self { Self(red: 0.56, green: 0.56, blue: 0.55) }
}

// MARK: Extensions
public extension ColorCodable {
 var intValue: Int32 {
  let r = Int32(red * 255) << 16
  let g = Int32(green * 255) << 8
  let b = Int32(blue * 255)
  let a = Int32(alpha * 255) << 24
  return r + g + b + a
 }

 static func random() -> Self {
  func random() -> Double {
   Double(arc4random_uniform(255)) / 255
  }
  return
   Self(fromComponents: (0 ..< 3).map { _ in random() } + [1])
 }
}

public extension ColorCodable {
 init<A: ColorCodable>(_ color: A) {
  self.init(
   red: color.red, green: color.green, blue: color.blue, alpha: color.alpha
  )
 }

 subscript(dynamicMember keyPath: KeyPath<Light, Light>) -> Self {
  Self(Light()[keyPath: keyPath])
 }

 static subscript(dynamicMember keyPath: KeyPath<Light, Light>) -> Self {
  Self(Light()[keyPath: keyPath])
 }

 /// The color with an alpha factor of 0.85.
 @_transparent
 var translucent: Self { alpha(0.85) }
 /// The color with an alpha factor of 0.675.
 @_transparent
 var faded: Self { alpha(0.675) }
 /// The color with an alpha factor of 0.5.
 @_transparent
 var light: Self { alpha(0.5) }
 /// The color with an alpha factor of 0.25.
 @_transparent
 var subtle: Self { alpha(0.25) }
 /// The color with an alpha factor of 0.15.
 @_transparent
 var faint: Self { alpha(0.15) }
 @_transparent
 static var shadow: Self { Self(white: 0, alpha: 0.33) }
 @_transparent
 static var highlight: Self { Self(white: 1, alpha: 0.33) }
}

#if canImport(SwiftUI)
 import struct SwiftUI.Color

 public extension Color {
//  init(_ color: NativeColor) {
//   self.init()
//   self.init(
//    red: color.red,
//    green: color.green,
//    blue: color.blue,
//    alpha: color.alpha
//   )
//  }
//
//  subscript(dynamicMember keyPath: KeyPath<Color, Color>) -> Self {
//   Self(Color()[keyPath: keyPath])
//  }
//
//  static subscript(dynamicMember keyPath: KeyPath<Color, Color>) -> Self {
//   Self(SwiftUI.Color()[keyPath: keyPath])
//  }
//
//  subscript(dynamicMember keyPath: KeyPath<NativeColor, NativeColor>) -> Self {
//   Self(NativeColor()[keyPath: keyPath])
//  }
//
//  static subscript(
//   dynamicMember keyPath: KeyPath<NativeColor, NativeColor>
//  ) -> Self {
//   Self(NativeColor()[keyPath: keyPath])
//  }

  #if os(iOS)
   @_transparent
   static var accent: Self {
    guard let color =
     NativeColor(named: "AccentColor") else {
     return Self(Color.accentColor)
    }
    return Self(color)
   }
  @_transparent
  static var background: Self { Self( .systemBackground) }
  @_transparent
  static var groupedBackground: Self {
   Self(.systemGroupedBackground)
  }
  
  @_transparent
  static var secondaryBackground: Self {
   Self( .secondarySystemBackground)
  }
  
  @_transparent
  static var tertiaryBackground: Self {
   Self(.tertiarySystemBackground)
  }
  
  @_transparent
  static var tertiaryFill: Self { Self( .tertiarySystemFill) }
  @_transparent
  static var secondaryGroupedBackground: Self {
   Self(.secondarySystemGroupedBackground)
  }
  
  @_transparent
  static var fill: Self { Self(.systemFill) }
  @_transparent
  static var secondaryFill: Self { Self(.secondarySystemFill) }
  @_transparent
  static var label: Self { Self(.label) }
  @_transparent
  static var secondaryLabel: Self { Self(.secondaryLabel) }
  @_transparent
  static var tertiaryLabel: Self { Self(.tertiaryLabel) }
  @_transparent
  static var placeholder: Self { Self(.placeholderText) }
  @_transparent
  static var separator: Self { Self(.separator) }
  @_transparent
  static var outline: Self { label.light }
   /// Adjusts to underlay the foreground color.
  func foregroundUnderlay(
   _ foreground: Self = .label
  ) -> Self {
   foreground.backgroundOverlay(self)
  }
  
   /// Adjusts to overlay the background color.
  func backgroundOverlay(_ background: Self? = .none) -> Self {
   (background ?? self).isDark ? Self.white : Self.black // .translucent
  }
  static var orangeRed: Self {
   .red.darkBlend(Color.orange)
  }
  

  #elseif os(macOS)
   //static var accentColor: Self { Self(.userAccent) }
  #endif
 }

 import SwiftUI

 #if os(iOS)
  public typealias NativeColor = UIColor
 #elseif os(macOS)
  public typealias NativeColor = NSColor
 #endif

 public extension NativeColor {
  convenience init(
   red: Double, green: Double, blue: Double, alpha: Double
  ) {
   self.init(
    red: CGFloat(red),
    green: CGFloat(green),
    blue: CGFloat(blue),
    alpha: CGFloat(alpha)
   )
  }

  var components: [Double] {
   var red: CGFloat = 0,
       green: CGFloat = 0,
       blue: CGFloat = 0,
       alpha: CGFloat = 0

   #if os(macOS)
    usingColorSpace(.sRGB)
   #endif
   getRed(&red, green: &green, blue: &blue, alpha: &alpha)
   return [
    Double(red),
    Double(green),
    Double(blue),
    Double(alpha)
   ]
  }

  var red: Double { components[0] }
  var green: Double { components[1] }
  var blue: Double { components[2] }
  var alpha: Double { components[3] }

  var hsbComponents: [Double] {
   var hue: CGFloat = 0,
       saturation: CGFloat = 0,
       brightness: CGFloat = 0,
       alpha: CGFloat = 0

   #if os(macOS)
    usingColorSpace(.sRGB)?
     .getHue(
      &hue,
      saturation: &saturation,
      brightness: &brightness,
      alpha: &alpha
     )
   #elseif os(iOS)
    getHue(
     &hue,
     saturation: &saturation,
     brightness: &brightness,
     alpha: &alpha
    )
   #endif
   return [
    Double(hue),
    Double(saturation),
    Double(brightness),
    Double(alpha)
   ]
  }
 }

// @dynamicMemberLookup
// public final class NativeColor: _NativeColor, ColorCodable {
//  public required convenience init(from decoder: Decoder) throws {
//   let container = try decoder.container(keyedBy: ColorCodingKeys.self)
//   let red = try container.decode(Double.self, forKey: .red)
//   let green = try container.decode(Double.self, forKey: .green)
//   let blue = try container.decode(Double.self, forKey: .blue)
//   let alpha = try container.decode(Double.self, forKey: .alpha)
//   self.init(red: red, green: green, blue: blue, alpha: alpha)
//  }
//
//  public func encode(to encoder: Encoder) throws {
//   var container = encoder.container(keyedBy: ColorCodingKeys.self)
//   try container.encode(red, forKey: .red)
//   try container.encode(green, forKey: .green)
//   try container.encode(blue, forKey: .blue)
//   try container.encode(alpha, forKey: .alpha)
//  }
// }
//
 @available(macOS 11.0, *)
 extension Color: ColorCodable {
  public var nativeColor: NativeColor {
   NativeColor(self)
  }

  public var components: [Double] {
   nativeColor.components
  }

  public var hsbComponents: [Double] {
   nativeColor.hsbComponents
  }

  public init(red: Double, green: Double, blue: Double, alpha: Double) {
   self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }
 }
//
// /// Extensions
// public extension _NativeColor {
//  #if os(macOS) // renames
//   @_transparent
//   static var userAccent: _NativeColor { .accentColor ?? .controlAccentColor }
//   @_transparent
//   static var systemAccent: _NativeColor { .controlAccentColor }
//   convenience init(
//    dynamicProvider: @escaping (NSAppearance) -> _NativeColor) {
//    self.init(name: nil, dynamicProvider: dynamicProvider)
//   }
//
//   static var systemBackground: _NativeColor { .windowBackgroundColor }
//   static var label: _NativeColor { .labelColor }
//   static var secondaryLabel: _NativeColor { .secondaryLabelColodr }
//   static var tertiaryLabel: _NativeColor { .tertiaryLabelColor }
//   static var placeholderText: _NativeColor { .placeholderTextColor }
//   static var separator: _NativeColor { .separatorColor }
//   static var systemGroupedBackground: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(white: 0.9254901960784314, alpha: 1)
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//
//   static var secondarySystemBackground: _NativeColor {
//    .systemGroupedBackground
//   }
//
//   static var tertiarySystemBackground: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(white: 0.8347558631295656, alpha: 1)
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//
//   static var secondarySystemGroupedBackground: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(
//         red: 0.47058823529411764,
//         green: 0.47058823529411764,
//         blue: 0.5019607843137255, alpha: 0.16
//        )
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//
//   static var systemFill: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(
//         red: 0.47058823529411764,
//         green: 0.47058823529411764,
//         blue: 0.5019607843137255, alpha: 0.2
//        )
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//
//   static var secondarySystemFill: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(
//         red: 0.47058823529411764,
//         green: 0.47058823529411764,
//         blue: 0.5019607843137255, alpha: 0.16
//        )
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//
//   static var tertiarySystemFill: _NativeColor {
//    _NativeColor(
//     dynamicProvider: { appearance in
//      switch appearance.name {
//       case .darkAqua:
//        return .init(
//         red: 0.4627450980392157,
//         green: 0.4627450980392157,
//         blue: 0.5019607843137255, alpha: 0.12
//        )
//       default: break
//      }
//      return .white
//     }
//    )
//   }
//  #endif
// }
#endif
