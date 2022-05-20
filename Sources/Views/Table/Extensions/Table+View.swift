import SwiftUI

public extension View {
#if os(iOS)
 func onPull(
  threshold: CGFloat = -80,
  impact: UIImpactFeedbackGenerator.FeedbackStyle? = .rigid,
  timeout: UInt32 = 10,
  delay: DispatchTime = .now(),
  isFinished: Binding<Bool>,
  perform: @escaping () -> Void
 ) -> PullView {
  PullView(
   threshold: threshold,
   impact: impact,
   timeout: timeout,
   delay: delay,
   isFinished: isFinished,
   content: self,
   action: perform
  )
 }
 #elseif os(macOS)
 func onPull(
  threshold: CGFloat = -80,
  timeout: UInt32 = 10,
  delay: DispatchTime = .now(),
  isFinished: Binding<Bool>,
  perform: @escaping () -> Void
 ) -> PullView {
  PullView(
   threshold: threshold,
   timeout: timeout,
   delay: delay,
   isFinished: isFinished,
   content: self,
   action: perform
  )
 }
 #endif
}

public extension PullView {
 func overscrollAction(
  offset: CGFloat = 1, perform: @escaping () -> Void
 ) -> PullView {
  var copy = self
  copy.overscrollAction = perform
  copy.overscrollOffset = offset
  return copy
 }
}
