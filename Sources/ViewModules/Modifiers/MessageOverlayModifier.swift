import SwiftUI
import Core

struct MessageOverlayModifier: ViewModifier {
 @Binding var overlay: MessageOverlay?
 @State private var isPresented: Bool = false
 let alignment: Alignment
 public func body(content: Content) -> some View {
  content
   .overlay(alignment) {
    if let overlay = overlay, isPresented {
     overlay
    }
   }
   .onChange(of: overlay, perform: update)
 }

 func update(_ overlay: MessageOverlay?) {
  guard let overlay = overlay else {
   // animation(.easeOut) {
   isPresented = false
   // }
   return
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + overlay.delay) {
   // animation(overlay.animation.speed(0.75)) {
   isPresented = true
   // }
   DispatchQueue.main.asyncAfter(
    deadline: .now() + (overlay.timeout - overlay.delay)
   ) {
    // animation(overlay.animation.speed(1.765)) {
    self.overlay?.content = .none
    self.overlay?.title = .none
    self.overlay?.style = .clear
    // }
    if self.overlay != nil {
     self.overlay = .none
    }
   }
  }
 }
}

public extension View {
 func messageOverlay(
  _ overlay: Binding<MessageOverlay?>,
  alignment: Alignment = .center
 ) -> some View {
  modifier(MessageOverlayModifier(overlay: overlay, alignment: alignment))
 }
}

/// A token that should be sent to a view modifier to trigger a message overlay.
/// - Note: Not in an `enum` because it's less result and more feedback orientated.
public struct MessageOverlay: View, Identifiable, Equatable {
 public var id: Int {
  (title?.hashValue ?? 0) + (subtitle?.hashValue ?? 0) + Int(timeout)
 }

 public static func == (lhs: MessageOverlay, rhs: MessageOverlay) -> Bool {
  lhs.title == rhs.title
   && lhs.subtitle == rhs.subtitle
   && lhs.style == rhs.style
   && lhs.timeout == rhs.timeout
 }

 public init<Content: View>(
  _ content: Content? = .none,
  title: String? = .none,
  subtitle: String? = .none,
  position: Position? = .top,
  anchor: Position? = .left,
  spacing: CGFloat? = 8.5,
  alignment: Alignment = .center,
  padding: CGFloat = 48,
  baseRadius: CGFloat = 250,
  textSize: CGFloat = 18,
  textWeight: Font.Weight = .semibold,
  scaleFactor: CGFloat = 0.85,
  style: BackdropForeground = .secondaryToolbar,
  cornerRadius: CGFloat = 11.5,
  delay: TimeInterval = 0.1,
  timeout: TimeInterval = 3,
  transition: AnyTransition = .opacity,
  animation: Animation = .alert,
  hitTesting: Bool = false
 ) {
  self.content = AnyView(content)
  self.title = title
  self.subtitle = subtitle
  self.position = position
  self.anchor = anchor
  self.spacing = spacing
  self.alignment = alignment
  self.padding = padding
  self.baseRadius = baseRadius
  self.textSize = textSize
  self.textWeight = textWeight
  self.scaleFactor = scaleFactor
  self.style = style
  self.cornerRadius = cornerRadius
  self.delay = delay
  self.timeout = timeout
  self.transition = transition
  self.animation = animation
  self.hitTesting = hitTesting
 }
 @Environment(\.colorScheme) private var colorScheme
 public var content: AnyView?,
            // MARK: - Content
            title: String?,
            subtitle: String?,
            /// Content position.
            position: Position!,
            anchor: Position!,
            spacing: CGFloat?,
            alignment: Alignment,
            padding: CGFloat,
            /// Centered content radius.
            baseRadius: CGFloat,
            textSize: CGFloat,
            textWeight: Font.Weight,
            scaleFactor: CGFloat,
            // MARK: - Background
            style: BackdropForeground,
            cornerRadius: CGFloat,
            // MARK: - Animatable Data
            delay: TimeInterval,
            timeout: TimeInterval,
            transition: AnyTransition,
            animation: Animation,
            hitTesting: Bool
 var isVertical: Bool { position.isVertical }
 var hasSubtitle: Bool { subtitle?.wrapped == nil }
 var isVerticalWithSubtitle: Bool { isVertical || hasSubtitle }
 var compensatedSpacing: CGFloat? {
  guard !isVerticalWithSubtitle, let spacing = spacing else { return 0 }
  return spacing / 2
 }

 var insetPadding: CGFloat { padding }

 var compensatedPadding: CGFloat {
  isVerticalWithSubtitle ? padding : padding * 0.5
 }

 var contentPadding: CGFloat { isVertical ? padding + 24 : padding * 0.22 }
 var compensatedContentPadding: CGFloat {
  isVerticalWithSubtitle ? contentPadding * 0.6 : 0
 }

 var compensatedTextPadding: CGFloat {
  isVerticalWithSubtitle ? 0 : padding * 0.11
 }

 var width: CGFloat {
  isVertical ? baseRadius - insetPadding : baseRadius
 }

 var height: CGFloat {
  isVertical ? width :
  baseRadius * (hasSubtitle ? 0.392 : 0.196)
 }

 var contentSize: CGFloat {
  isVerticalWithSubtitle ? height - insetPadding :
   height - compensatedPadding
 }

 var fontSize: CGFloat { isVertical ? textSize : textSize * 0.85 }
 var subtitleSize: CGFloat { fontSize * 0.9 }
 var backdropRadius: CGFloat { isVertical ? cornerRadius : cornerRadius * 0.5 }
 public var body: some View {
  style.backdrop
   .frame(width: width, height: height)
//   .outline(
//    color: (style.backdrop.color ?? .label).highlight,
//    corners: .all,
//    cornerRadius: cornerRadius,
//    width: 1
//   )
   .cornerRadius(cornerRadius, antialiased: true)
   .outline(
    color:
     (colorScheme == .dark ? Color.black.faint :
       (style.backdrop.color ?? style.foreground).shadow.faint.light),
    corners: .all,
    cornerRadius: cornerRadius,
    width: 1
   )
   .shadow(
    color: .shadow.faint,
    radius: insetPadding * 0.33, x: 0, y: 0
   )
   .padding(insetPadding)
   .overlay(
    VerticalContent(.top, spacing: spacing) {
     PositionalContent(
      alignment,
      position: position,
      anchor: anchor,
      spacing: spacing
     ) {
      content
       .aspectRatio(1, contentMode: .fill)
       .frame(height: contentSize)
       .frame(maxWidth: contentSize)
       .padding(compensatedContentPadding)
       |>
      Text.Optional(title?.wrapped)
       .font(.system(size: fontSize, weight: textWeight))
       .lineLimit(1)
       .multilineTextAlignment(alignment.text)
       .minimumScaleFactor(scaleFactor)
     }
      |>
      Text.Optional(subtitle?.wrapped)
      .font(.system(size: subtitleSize, weight: textWeight))
      .lineLimit(2)
      .multilineTextAlignment(alignment.text)
      .foregroundColor(.tertiaryLabel)
    }
    .padding(contentPadding)
     .padding(isVertical ? .bottom : .empty, 15)
    .foregroundColor(style.foreground)
   )
//
//  .frame(maxWidth: maxWidth, maxHeight: maxHeight)
//  .padding(compensatedPadding)
//  .backdrop(
//   style,
//   outline: .tertiaryLabel.faint,
//   padding: insetPadding,
//   cornerRadius: backdropRadius
//  )
   // .transition(transition.animation(animation))
   .allowsHitTesting(hitTesting)
 }
}
