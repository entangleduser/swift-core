#if os(iOS)
import SwiftUI
import Storage

extension UIFont {
 @objc open var defaultFontFamily: String {
  Settings.default.fontFamily ?? UIFont.systemFont(ofSize: 15).familyName
 }

 public class var defaultFontFamily: String { UIFont().defaultFontFamily }
 @objc open var fontSizeOffset: CGFloat { 0 }
 class var fontSizeOffset: CGFloat { UIFont().fontSizeOffset }
 @objc open var fontWeightOffset: CGFloat { 0 }
 class var fontWeightOffset: CGFloat { UIFont().fontWeightOffset }
}

@nonobjc public extension UIFont {
 class func customPreferredFont(
  forTextStyle style: UIFont.TextStyle
 ) -> UIFont {
  return customFont(style)
 }

 class func ultraLightCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .ultraLight)
 }

 class func lightCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .light)
 }

 class func regularCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .regular)
 }

 class func mediumCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .medium)
 }

 class func semiboldCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .semibold)
 }

 class func boldCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, traits: .traitBold)
 }

 class func heavyCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .heavy)
 }

 class func blackCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, weight: .black)
 }

 class func italicCustomFont(ofSize size: CGFloat) -> UIFont {
  customFont(ofSize: size, traits: .traitItalic)
 }
 typealias AttributedTraits = [UIFontDescriptor.TraitKey: Any]
 typealias Attributes = [UIFontDescriptor.AttributeName: Any]
 typealias SymbolicTraits = UIFontDescriptor.SymbolicTraits
 class func customFont(
  _ style: TextStyle? = .none,
  ofSize size: CGFloat? = .none,
  weight: Weight? = .none,
  traits: SymbolicTraits? = .none,
  withAttributes attributes: Attributes? = .none
 ) -> UIFont {
//  guard
  var descriptor = UIFontDescriptor()
  var attr = descriptor.fontAttributes
  var newTraits = descriptor.fontAttributes[.traits] as? AttributedTraits
//  else { fatalError("Couldn't find resource for font \(defaultFontFamily)") }
//  func addTraitsIfNeeded() {
//   attr[.symbolic].formUnion(traits)
//  }
  func appendSymbolicTraits(_ value: Any) {
   guard let value = value as? SymbolicTraits, !value.isEmpty else { return }
   if newTraits?[.symbolic] == nil
       || (newTraits?[.symbolic] as? SymbolicTraits)?.isEmpty ?? true {
    newTraits?[.symbolic] = value
   } else if let oldValue = newTraits?[.symbolic] as? SymbolicTraits {
    newTraits?[.symbolic] = oldValue.union(value)
   }
  }
  func appendTrait(_ key: UIFontDescriptor.TraitKey, _ value: Any) {
   if newTraits == nil
       || newTraits?.isEmpty ?? true {
    newTraits = AttributedTraits.empty
   }
   if key == .symbolic {
    appendSymbolicTraits(value)
   } else {
   newTraits?[key] = value
   }
  }
  if let style = style {
   descriptor = .preferredFontDescriptor(withTextStyle: style)
   attr[.textStyle] = style
  }
  if let traits = traits { appendSymbolicTraits(traits) }
  if let weight = weight {
   appendTrait(.weight, NSNumber(nonretainedObject: weight.rawValue))
  }
  if let attributes = attributes {
   for (key, value) in attributes {
    if let traits = value as? AttributedTraits {
     for (key, value) in traits { appendTrait(key, value) }
    }
    else { attr[key] = value }
   }
  }
  if let newTraits = newTraits, newTraits.notEmpty,
     var traits = attr[.traits] as? AttributedTraits {
   for (key, value) in newTraits {
    traits[key] = value
   }
   attr[.traits] = traits
  }
  if let traits = (attr[.traits] as? AttributedTraits)?[.symbolic] as? SymbolicTraits,
     let newDescriptor =
      descriptor.withSymbolicTraits(traits.union(descriptor.symbolicTraits)) {
   descriptor = newDescriptor
  }
  let newSize = size ?? descriptor.pointSize
  attr[.size] = newSize
  if attr.notEmpty { descriptor = descriptor.addingAttributes(attr) }
  let finalDescriptor =
  descriptor
   .withFamily(defaultFontFamily)
   .withSize(newSize)
  return UIFont(descriptor: finalDescriptor, size: finalDescriptor.pointSize)
 }
}

extension UIFont.Weight {
 var attributed: [UIFontDescriptor.TraitKey: CGFloat] {
  [.weight: self.rawValue]
 }
}

public extension Font {
 static func traits(
  _ traits: Traits = .optimized,
  size: CGFloat = UIFont.systemFontSize
 ) -> Self {
  Self(UIFont.customFont(ofSize: size, withAttributes: traits.attributes))
 }

 static func style(
  _ style: TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  weight: Weight? = .none,
  traits: Traits? = .none
 ) -> Self {
  return Self(
   UIFont.customFont(
    style?.native,
    ofSize: size,
    weight: weight?.native,
    traits: traits?.symbolic,
    withAttributes: traits?.attributes
   )
  )
 }
}

extension Font.TextStyle {
 var native: UIFont.TextStyle {
  switch self {
   case .largeTitle: return .largeTitle
   case .title: return .title1
   case .title2: return .title2
   case .title3: return .title3
   case .headline: return .headline
   case .subheadline: return .subheadline
   case .body: return .body
   case .callout: return .callout
   case .caption: return .caption1
   case .caption2: return .caption2
   case .footnote: return .footnote
   default: return .body
  }
 }
}

extension Font.Weight {
 var native: UIFont.Weight {
  switch self {
   case .regular: return .regular
   case .ultraLight: return .ultraLight
   case .light: return .light
   case .medium: return .medium
   case .semibold: return .semibold
   case .bold: return .bold
   case .heavy: return .heavy
   case .black: return .black
   default: fatalError("Font weight not implemented!")
  }
 }

 var attributed: [UIFontDescriptor.TraitKey: CGFloat] {
  native.attributed
 }
}

public extension Font {
 struct Traits: OptionSet, Sequence {
  public let rawValue: Int8
  public static let regular: Self = .empty
  public static let light = Self(rawValue: 1 << 1)
  public static let medium = Self(rawValue: 1 << 2)
  public static let semibold = Self(rawValue: 1 << 3)
  public static let bold = Self(rawValue: 1 << 4)
  public static let heavy = Self(rawValue: 1 << 5)
  public static let black = Self(rawValue: 1 << 6)
  public static let italic = Self(rawValue: 1 << 7)
  public static let condensed = Self(rawValue: 1 << 8)
  public static let expanded = Self(rawValue: 1 << 9)
  public static let loose = Self(rawValue: 1 << 10)
  public static let tight = Self(rawValue: 1 << 11)
  public static let monospaced = Self(rawValue: 1 << 12)
  public static let optimized = Self(rawValue: 1 << 13)

  public static let italicBold: Self = [.italic, .bold]
  public static let condensedBold: Self = [.condensed, .bold]
  public static let tightBold: Self = [.tight, .bold]
  public static let optimalBold: Self = [.optimized, .bold]

  public init(rawValue: Int8) { self.rawValue = rawValue }
  var weight: UIFont.Weight? {
   switch self {
    case .regular, .empty: return nil
    case .light: return .light
    case .medium: return .medium
    case .semibold: return .semibold
    case .bold: return nil
    case .heavy: return .heavy
    case .black: return .black
    default: return nil
   }
  }

  var attributedWeight: [UIFontDescriptor.TraitKey: CGFloat]? {
   weight?.attributed
  }

  private var _symbolic: UIFontDescriptor.SymbolicTraits? {
   switch self {
    case .regular, .empty: return nil
    case .bold: return .traitBold
    case .italic: return .traitItalic
    case .condensed: return .traitCondensed
    case .expanded: return .traitExpanded
    case .loose: return .traitLooseLeading
    case .tight: return .traitTightLeading
    case .monospaced: return .traitMonoSpace
    case .optimized: return .traitUIOptimized
    default: return nil
   }
  }

  var symbolic: UIFontDescriptor.SymbolicTraits? {
   if let symbolic = _symbolic { return symbolic } else {
    var traits: UIFontDescriptor.SymbolicTraits = .empty
    for `case` in self {
     guard let trait = `case`._symbolic else { continue }
     traits.insert(trait)
    }
    guard !traits.isEmpty else { return nil }
    return traits
   }
  }

  var attributes: [UIFontDescriptor.AttributeName: Any]? {
   guard let attributedWeight = attributedWeight else { return nil }
   return [.traits: attributedWeight]
  }
 }
}

public extension Text {
 func fontStyle(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  weight: Font.Weight? = .none,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: weight, traits: traits))
 }

 func black(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .black, traits: traits))
 }

 func heavy(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .heavy, traits: traits))
 }

 func bold(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .bold, traits: traits))
 }

 func semibold(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .semibold, traits: traits))
 }

 func medium(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .medium, traits: traits))
 }

 func light(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> Self {
  font(.style(style, size: size, weight: .light, traits: traits))
 }
}

public extension View {
 @_disfavoredOverload
 func fontStyle(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  weight: Font.Weight? = .none,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: weight, traits: traits))
 }

 @_disfavoredOverload
 func black(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .black, traits: traits))
 }

 @_disfavoredOverload
 func heavy(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .heavy, traits: traits))
 }

 @_disfavoredOverload
 func bold(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .bold, traits: traits))
 }

 @_disfavoredOverload
 func semibold(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .semibold, traits: traits))
 }

 @_disfavoredOverload
 func medium(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .medium, traits: traits))
 }

 @_disfavoredOverload
 func light(
  _ style: Font.TextStyle? = .none,
  size: CGFloat = UIFont.systemFontSize,
  traits: Font.Traits = .optimized
 ) -> some View {
  font(.style(style, size: size, weight: .light, traits: traits))
 }
}

// MARK: - Swizzle Methods
@objc public extension UIFont {
 class func _preferredFont(
  forTextStyle style: UIFont.TextStyle
 ) -> UIFont {
  let descriptor: UIFontDescriptor =
   _preferredFont(forTextStyle: style).fontDescriptor
    .withFamily(defaultFontFamily)
  return
   UIFont(descriptor: descriptor, size: descriptor.pointSize + fontSizeOffset)
 }

 class func _customSystemFont(
  ofSize size: CGFloat, weight: UIFont.Weight = .regular
 ) -> UIFont {
  customFont(ofSize: size, weight: weight)
 }

 class func _boldCustomFont(ofSize size: CGFloat) -> UIFont {
  boldCustomFont(ofSize: size)
 }

 class func _italicCustomFont(ofSize size: CGFloat) -> UIFont {
  italicCustomFont(ofSize: size)
 }
}

// @objc public extension UIFontDescriptor {
// func _withFamily(_: String) -> UIFontDescriptor {
//  _withFamily(UIFont.defaultFontFamily)
// }
//
// class func _preferredFontDescriptor(
//  withTextStyle style: UIFont.TextStyle
// ) -> UIFontDescriptor {
//  _preferredFontDescriptor(withTextStyle: style)
//   .withFamily(UIFont.defaultFontFamily)
// }
// }

extension UIFont.Weight: CaseIterable {
 public static let allCases: [Self] = [
  .light,
  .regular,
  .medium,
  .semibold,
  .bold,
  .heavy,
  .black
 ]
}
#endif
