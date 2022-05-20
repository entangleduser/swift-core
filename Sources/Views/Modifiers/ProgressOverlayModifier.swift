import SwiftUI
import Storage

struct ProgressOverlayModifier: ViewModifier {
 let isPresented: Bool
 let title: String?
 let subtitle: String?
 let style: BackdropForeground
 let position: Position
 let alignment: Alignment
 let max: TimeInterval
 let timeout: TimeInterval
 let transition: AnyTransition
 let animation: Animation
 @State var overlay: MessageOverlay?

 func body(content: Content) -> some View {
  content
   .messageOverlay($overlay, alignment: alignment)
   .onChange(of: isPresented, perform: update)
 }

 func update(_ isPresented: Bool) {
  overlay =
   MessageOverlay(
    ProgressView().progressViewStyle(CircularProgressViewStyle()).bold(.title)
     .scaleEffect(position.isVertical ? 2 : 1),
    title: title,
    subtitle: subtitle,
    position: position,
    style: style,
    delay: 0,
    timeout: isPresented ? max : timeout,
    transition: transition,
    animation: animation
   )
 }
}

public extension View {
 func progressOverlay(
  _ isPresented: Bool,
  title: String? = "Loading",
  subtitle: String? = .none,
  style: BackdropForeground = .tertiaryOverlay,
  position: Position = .top,
  alignment: Alignment = .center,
  max: TimeInterval = 3,
  timeout: TimeInterval = 0.45,
  transition: AnyTransition =
   .asymmetric(
    insertion: .opacity.animation(.easeIn(duration: 0.1)), removal: .opacity
   ),
  animation: Animation = .easeOut(duration: 0.5)
 ) -> some View {
  modifier(
   ProgressOverlayModifier(
    isPresented: isPresented,
    title: title,
    subtitle: subtitle,
    style: style,
    position: position,
    alignment: alignment,
    max: max,
    timeout: timeout,
    transition: transition,
    animation: animation
   )
  )
 }
}
