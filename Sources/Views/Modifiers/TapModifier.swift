import SwiftUI

public struct TapContent<Content: View>: View {
 public init(
  animation: Animation = .easeInOut,
  onEnded: (() -> ())? = nil,
  content: @escaping (Bool) -> Content
 ) {
  self.animation = animation
  self.onEnded = onEnded
  self.content = content
 }
 
 let animation: Animation
 @State private var didTap: Bool = false
 public var onEnded: (() -> ())?
 @ViewBuilder public var content: (Bool) -> Content
 @State var contentBounds: CGRect = .zero
 
 public var body: some View {
  content(didTap)
   .gesture(
    DragGesture(minimumDistance: 0, coordinateSpace: .local)
     .onChanged { gesture in
      if !didTap, contentBounds.contains(gesture.location) {
       withAnimation(animation) { didTap = true }
      } else {
       withAnimation(animation) { didTap = false }
      }
     }
     .onEnded { _ in
      onEnded?()
      withAnimation(animation) { didTap = false }
     }, including: .all
   )
   .readFrame($contentBounds)
 }
}

public extension View {
 @ViewBuilder func onTap<Content>(
  animation: Animation = .easeInOut,
  onEnded: (() -> ())? = .none,
  @ViewBuilder content: @escaping (Bool, Self) -> Content
 ) -> some View
 where Content: View {
  TapContent(animation: animation, onEnded: onEnded, content: { content($0, self) })
 }
}

