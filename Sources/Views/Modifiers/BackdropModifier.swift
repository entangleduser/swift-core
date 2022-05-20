import SwiftUI
import Storage

public struct Backdrop: View, Equatable {
 public static func == (lhs: Backdrop, rhs: Backdrop) -> Bool {
  lhs.color == rhs.color
   && lhs.style == rhs.style
   && lhs.vibrancy == rhs.vibrancy
   && lhs.disabled == rhs.disabled
 }

 @Environment(\.colorScheme) var colorScheme
 @Environment(\.reducedBlur) var reducedBlur
 @ObservedObject private var settings: Settings = .default
 public init(
  _ color: Color? = .none,
  style: UIBlurEffect.Style = .regular,
  vibrancy: UIVibrancyEffectStyle? = .none,
  disabled: Bool? = .none
 ) {
  self.color = color
  self.style = style
  self.vibrancy = vibrancy
  self.disabled = disabled
 }

 public let color: Color?
 public let style: UIBlurEffect.Style
 public let vibrancy: UIVibrancyEffectStyle?
 public let disabled: Bool?
 public var body: some View {
  if disabled ?? reducedBlur ?? settings.reducedBlur {
   if let color = color, color.isOpaque
    || (self.disabled.unwrapped && color == .clear) { color }
   else {
    colorScheme == .dark ? Color.tertiaryBackground : Color.secondaryBackground
   }
  } else {
   (color ?? Color.clear)
    .blurEffect(style, vibrancy: vibrancy, disabled: disabled)
  }
 }
}

public struct BackdropForeground: Equatable {
 public var
  backdrop: Backdrop,
  foreground: Color,
  vibrancy: UIVibrancyEffectStyle? = .none
}

public extension BackdropForeground {
 init(
  _ backdrop: Backdrop,
  _ foreground: Color = .clear,
  _ vibrancy: UIVibrancyEffectStyle? = .none
 ) {
  self.backdrop = backdrop
  self.foreground = foreground
  self.vibrancy = vibrancy
 }
}

public extension Backdrop {
 static let clear = Self(.clear, disabled: true)
 static let primary = Self()
 static let secondary = Self(.secondaryBackground)
 static let tertiary = Self(.tertiaryBackground)
 static let grouped = Self(.groupedBackground)
 static let secondaryGrouped = Self(.secondaryGroupedBackground)
 static let primaryFill = Self(.fill)
 static let secondaryFill = Self(.secondaryFill)
 static let tertiaryFill = Self(.tertiaryFill)
 static let chrome = Self(style: .systemChromeMaterial)
 static let toolbar = Self(style: .systemThickMaterial)
}

public extension BackdropForeground {
 static func style(_ style: Self, with vibrancy: UIVibrancyEffectStyle) -> Self {
  var `self` = style
  self.vibrancy = vibrancy
  return self
 }

 static let clear =
  Self(backdrop: .clear, foreground: .clear)
 static let primary =
  Self(backdrop: .primary, foreground: .secondary)
 static let secondary =
  Self(backdrop: .secondary, foreground: .secondary)
 static let tertiary =
  Self(backdrop: .tertiary, foreground: .secondary)
 static let grouped =
  Self(backdrop: .grouped, foreground: .secondary)
 static let secondaryGrouped =
  Self(backdrop: .secondaryGrouped, foreground: .secondary)
 static let chrome =
  Self(backdrop: .chrome, foreground: .secondary)
 static let toolbar =
  Self(backdrop: .toolbar, foreground: .primary)
 static let secondaryToolbar =
  Self(backdrop: .toolbar, foreground: .secondary)
 static let overlay =
  Self(backdrop: .primaryFill, foreground: .secondary)
 static let secondaryOverlay =
  Self(backdrop: .secondaryFill, foreground: .secondary)
 static let tertiaryOverlay =
  Self(backdrop: .tertiaryFill, foreground: .secondary)
 static let secondaryLabel =
  Self(backdrop: .clear, foreground: .secondary)
 static let light =
  Self(backdrop: .clear, foreground: .white.faded)
 static let lightOverlay =
  Self(backdrop: .primaryFill, foreground: .white.faded)
}

struct BackdropView: View {
 let style: Backdrop
 let inline: Color
 let outline: Color
 let lineWidth: CGFloat
 let padding: CGFloat
 let cornerRadius: CGFloat
 let corners: CornerSet
 let shadowColor: Color
 let shadowRadius: CGFloat
 let shadowX: CGFloat
 let shadowY: CGFloat
 let x: CGFloat
 let y: CGFloat

 var body: some View {
  style.equatable()
   .outline(
    color: inline,
    corners: corners,
    cornerRadius: cornerRadius,
    width: lineWidth
   )
   .cornerRadius(corners, cornerRadius)
   .outline(
    color: outline,
    corners: corners,
    cornerRadius: cornerRadius,
    width: lineWidth
   )
   .offset(x: x, y: y)
   .padding(padding)
   .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
 }
}

struct BackdropModifier: ViewModifier {
 let style: Backdrop
 let foreground: Color?
 let inline: Color
 let outline: Color
 let lineWidth: CGFloat
 let padding: CGFloat
 let cornerRadius: CGFloat
 let corners: CornerSet
 let shadowColor: Color
 let shadowRadius: CGFloat
 let shadowX: CGFloat
 let shadowY: CGFloat
 let x: CGFloat
 let y: CGFloat
 func body(content: Content) -> some View {
  content
   .backgroundColor(.clear)
   .background(
    BackdropView(
     style: style,
     inline: inline,
     outline: outline,
     lineWidth: lineWidth,
     padding: padding,
     cornerRadius: cornerRadius,
     corners: corners,
     shadowColor: shadowColor,
     shadowRadius: shadowRadius,
     shadowX: shadowX, shadowY: shadowY,
     x: x, y: y
    )
   )
   .foregroundColor(foreground)
 }
}

public extension View {
 func backdrop(
  _ style: Backdrop,
  foreground: Color?,
  inline: Color = .clear,
  outline: Color = .separator.subtle,
  lineWidth: CGFloat = 0.5,
  padding: CGFloat = 0,
  cornerRadius: CGFloat = 0,
  corners: CornerSet = .all,
  shadowColor: Color = .clear,
  shadowRadius: CGFloat = 0.5,
  shadowX: CGFloat = 0,
  shadowY: CGFloat = 0.5,
  x: CGFloat = 0, y: CGFloat = 0
 ) -> some View {
  modifier(
   BackdropModifier(
    style: style,
    foreground: foreground,
    inline: inline,
    outline: outline,
    lineWidth: lineWidth,
    padding: padding,
    cornerRadius: cornerRadius,
    corners: corners,
    shadowColor: shadowColor,
    shadowRadius: shadowRadius,
    shadowX: shadowX,
    shadowY: shadowY,
    x: x, y: y
   )
  )
 }

 func backdrop(
  _ style: BackdropForeground,
  inline: Color = .clear,
  outline: Color = .separator.subtle,
  lineWidth: CGFloat = 0.5,
  padding: CGFloat = 0,
  cornerRadius: CGFloat = 0,
  corners: CornerSet = .all,
  shadowColor: Color = .clear,
  shadowRadius: CGFloat = 1,
  shadowX: CGFloat = 0,
  shadowY: CGFloat = 0.5,
  x: CGFloat = 0, y: CGFloat = 0
 ) -> some View {
  modifier(
   BackdropModifier(
    style: style.backdrop,
    foreground: style.foreground,
    inline: inline,
    outline: outline,
    lineWidth: lineWidth,
    padding: padding,
    cornerRadius: cornerRadius,
    corners: corners,
    shadowColor: shadowColor,
    shadowRadius: shadowRadius,
    shadowX: shadowX,
    shadowY: shadowY,
    x: x, y: y
   )
  )
 }
}
