import SwiftUI

@available(macOS 11.0, *)
public struct SplitView<UpperContent: View, LowerContent: View>: View {
 @Binding var position: Position?
 @State var offset: CGFloat = .screen.midY {
  didSet {
   proxy = .init(from: self)
  }
 }

 @State private var topInset: CGFloat
 @State private var bottomInset: CGFloat
 @State private var handleHeight: CGFloat
 @State private var isPressed: Bool = false
 let blur: Edge.Set
 let animation: Animation
 let onTap: ((_ position: inout Position?) -> ())?
 var minOffset: CGFloat { topInset + handleHeight }
 var maxOffset: CGFloat { .screen.height - bottomInset }
 var midOffset: CGFloat = .screen.midY
 @ViewBuilder var upperContent: () -> UpperContent
 @ViewBuilder var lowerContent: () -> LowerContent
 var atBottom: Bool { offset >= maxOffset - handleHeight }
 var atTop: Bool { offset <= minOffset + handleHeight }
 var upperBounds: CGSize { .init(width: .screen.width, height: offset) }
 var lowerBounds: CGSize {
  .init(width: .screen.width, height: .screen.height - offset)
 }
 @Binding var proxy: SplitViewProxy?
 public var body: some View {
  VStack(spacing: 0) {
   upperContent()
    .blur(radius: blur.contains(.top) && isPressed ? 10 : 0, opaque: true)
    .frame(minHeight: minOffset)
    .frame(maxHeight: offset, alignment: .top)
    .overlay(
     StateButton(
      action: { withAnimation(animation.speed(0.2)) { isPressed = false } },
      label: { state in
       HStack {
        handle { atBottom ? .bottom : atTop ? .top : .center }
         .padding(atBottom ? .bottom : .top, 22)
         .foregroundColor(.secondaryLabel.opacity(state.isFocused ? 0.8 : 1))
         .onTapGesture { resetOffset() }
       }
       .frame(maxWidth: .infinity)
       .frame(height: handleHeight)
       .contentShape(Rectangle())
//       .impact(
//        onChange: isPressed || state.isFocused, \.light, intensity: 0.85
//       )
       .highPriorityGesture(
        DragGesture(minimumDistance: 0.001, coordinateSpace: .global)
         .onChanged { gesture in
          let newValue = gesture.location.y
          if !isPressed {
           withAnimation(animation.speed(0.2)) { isPressed = true }
          }
          guard newValue < maxOffset, newValue > minOffset else { return }
          offset = newValue
         }
         .onEnded { _ in
          position = atTop ? .top : atBottom ? .bottom : .none
          withAnimation(animation) { isPressed = false }
         }
       )
      }
     ),
     alignment: .bottom
    )
   lowerContent()
    .blur(radius: blur.contains(.bottom) && isPressed ? 10 : 0, opaque: true)
    .frame(minHeight: minOffset)
    .frame(maxHeight: lowerBounds.height, alignment: .bottom)
  }
  .onChange(of: position) { newValue in
   guard let newValue = newValue else { return }
   withAnimation(animation) {
    switch newValue {
    case .top: offset = minOffset
    case .bottom: offset = maxOffset
    default: offset = midOffset
    }
   }
  }
  .onAppear {
   proxy = .init(from: self)
  }
 }

 func resetOffset() {
  var newPosition: Position? =
   offset < 0 || atBottom || atTop ? .center : .bottom
  onTap?(&newPosition)
  withAnimation(animation) {
   position = newPosition
   isPressed = false
  }
 }
}

@available(macOS 11.0, *)
public extension SplitView {
 init(
  position: Binding<Position?> = .constant(.none),
  proxy: Binding<SplitViewProxy?> = .constant(.none),
  topInset: CGFloat = .insets.top,
  bottomInset: CGFloat = .insets.bottom,
  midOffset: CGFloat = .screen.height / 2,
  handleHeight: CGFloat = 56,
  blurOn: Edge.Set = .empty,
  animation: Animation = .interactive,
  onTap: ((_ position: inout Position?) -> ())? = .none,
  @ViewBuilder upperContent: @escaping () -> UpperContent,
  @ViewBuilder lowerContent: @escaping () -> LowerContent
 ) {
  _position = position
  _proxy = proxy
  self.topInset = topInset
  self.bottomInset = bottomInset
  self.midOffset = midOffset
  self.handleHeight = handleHeight
  self.blur = blurOn
  self.animation = animation
  self.onTap = onTap
  self.upperContent = upperContent
  self.lowerContent = lowerContent
 }
}

public struct SplitViewProxy {
 public var offset: CGFloat = 0,
            upperBounds: CGSize = .zero,
            lowerBounds: CGSize = .zero
}

@available(macOS 11.0, *)
public extension SplitViewProxy {
 init<A: View, B: View>(from splitView: SplitView<A, B>) {
  offset = splitView.offset
  upperBounds = splitView.upperBounds
  lowerBounds = splitView.lowerBounds
 }
}
