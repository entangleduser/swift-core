import SwiftUI

@available(macOS 11.0, *)
public struct Modal<Content: View, Background: View>: View {
 @Environment(\.colorScheme) var colorScheme
 //@StateObject var keyboard: KeyboardManager = .shared
// @Environment(\.presentationMode) var mode {
//  willSet {
//   self.isPresented = newValue.wrappedValue.isPresented
//  }
// }
 @Binding var isPresented: Bool
 let perform: (() -> ())?
 let pullAction: (() -> ())?
 let nudgeAction: (() -> ())?
 @Binding var proxy: ModalProxy?
 let animation: Animation
 let pullFactor: CGFloat
 let dragDisabled: Bool
 let showsHandle: Bool
 let ignoresKeyboard: Bool
 let dismissKeyboard: Bool
 @State var offset: CGFloat = 0 {
  didSet { proxy = .init(from: self) }
 }
 
 let idealHeight: CGFloat?
 let peekDistance: CGFloat?
 let peeksTransparently: Bool
 let showsArrow: Bool
 @State var adjustedOffset: CGFloat = .insets.bottom
 let opacity: CGFloat
 let background: (() -> (Background))?
 var cornerRadius: CGFloat = 11.5
 let shadowColor: Color
 let shadowRadius: CGFloat
 let shadowOffset: CGSize
 @State var contentSize: CGSize = .zero {
  didSet { proxy = .init(from: self) }
 }
 @ViewBuilder var content: () -> Content
 
 var isPeeking: Bool { !isPresented && peekDistance != nil }
 
 var contentShape: RoundedPath {
  RoundedPath(radius: cornerRadius, corners: .top)
 }
 
 var projectedHeight: CGFloat { .screen.height }
 var topInset: CGFloat { .insets.top }
 var maxHeight: CGFloat { projectedHeight - topInset }
 var contentHeight: CGFloat {
  (idealHeight ?? contentSize.height) + adjustedOffset
 }
 var peekHeight: CGFloat {
  peekDistance != nil ? peekDistance! + .insets.bottom : 0
 }
 var negativeHeight: CGFloat { maxHeight - contentHeight - peekHeight }
 
 var positiveHeight: CGFloat { projectedHeight - negativeHeight - peekHeight }
 
 var negativeThreshold: CGFloat {
  negativeHeight * pullFactor
 }
 
 var positiveThreshold: CGFloat {
  contentHeight * pullFactor
 }
 
 var minThreshold: CGFloat {
  -negativeThreshold
 }
 
 var maxThreshold: CGFloat {
  positiveThreshold
 }
 
 var threshold: CGFloat {
  contentHeight > negativeHeight ? minThreshold : maxThreshold
 }
 
 var isMinimizing: Bool {
  offset > 0
 }
 
 var translation: CGFloat {
  isMinimizing ? offset : -offset
 }
 
 var maxTranslation: CGFloat { contentHeight - peekHeight }
 var minTranslation: CGFloat { -maxTranslation }
 
 var negativeOffsetDegree: CGFloat {
  let degree = isMinimizing ? 0 : (translation / negativeHeight)
  return degree < 1 ? degree : 0
 }
 
 var positiveOffsetDegree: CGFloat {
  let degree = isMinimizing ? (translation / positiveHeight) : 0
  return degree < 1 ? degree : 0
 }
 
 var negativeThresholdDegree: CGFloat {
  let degree = (offset / negativeThreshold)
  return degree < 1 ? degree : 0
 }
 
 var positiveThresholdDegree: CGFloat {
  let degree = (offset / positiveThreshold)
  return degree < 1 ? degree : 0
 }
 
 var thresholdOffsetDegree: CGFloat {
  let degree = (offset / threshold)
  return degree < 1 ? degree : 0
 }
 
 var thresholdTranslationDegree: CGFloat {
  let degree = (translation / threshold)
  return degree < 1 ? degree : 0
 }
 
 var minOffset: CGFloat {
  contentHeight - offset > maxHeight ?
  topInset :
  (projectedHeight - contentHeight) + offset
 }
 
 var maxOffset: CGFloat {
  projectedHeight - (peekDistance ?? 0)
 }
 
 var projectedOffset: CGFloat {
  isPresented ? minOffset : maxOffset + (isPeeking && offset < 0 ? offset : 0)
 }
 
 var negativePeekDegree: CGFloat { offset / minTranslation }
 var positivePeekDegree: CGFloat { offset / maxTranslation }
 var peekDegree: CGFloat {
  isPeeking ? negativePeekDegree : 1 - positivePeekDegree
 }
 
 var peekFactor: CGFloat { isPeeking ? negativePeekDegree : positivePeekDegree }
 
 var gesture: _EndedGesture<_ChangedGesture<DragGesture>> {
  DragGesture(minimumDistance: 0, coordinateSpace: .global)
   .onChanged(onChanged)
   .onEnded(onEnded)
 }
 
// var keyboardPresented: Bool {
//  keyboard.keyboardVisible
// }
// var adjustedAnimation: Animation {
//  keyboardPresented ? keyboard.keyboardAnimation : self.animation
// }
 public var body: some View {
  content()
   //.ignoresSafeArea(.keyboard)
   .padding(.bottom, .insets.bottom)
   .introspectTextView {
    $0.keyboardDismissMode = .interactive
    $0.alwaysBounceVertical = true
   }
    .readSize($contentSize)
//#if os(iOS)
//   .ignoresSafeArea(ignoresKeyboard ? .keyboard : .empty)
//#endif
   .frame(height: projectedHeight, alignment: .top)
   .frame(maxWidth: .screen.width)
   //.frame(idealWidth: contentSize.width)
   .background(
    Group {
     if let background = background {
      background()
     } else {
#if os(iOS)
      Backdrop(style: .systemThickMaterial)
#elseif os(macOS)
      Color(.windowBackgroundColor)
#endif
     }
    }
     .mask(contentShape)
     .outline(
      color: isPresented || offset != 0 ? shadowColor.light : .clear,
      corners: .top,
      cornerRadius: cornerRadius
     )
     .shadow(
      color: isPresented || offset != 0 ? shadowColor.subtle : .clear,
      radius: shadowRadius,
      x: shadowOffset.width,
      y: shadowOffset.height
     )
     .opacity(
      peeksTransparently ? peekDegree : 1
     )
   )
   .overlay(.top) {
    if showsHandle {
     StateButton(
      action: {
       if isPresented {
        withAnimation(animation) { isPresented = false }
       } else {
        withAnimation(animation) { isPresented = true }
       }
       update(isPresented)
      },
      label: { state in
       //      let heightRatio =
       //      (isPeeking ? (peekHeight / 36) * negativePeekDegree : (36 / peekHeight) * positivePeekDegree)
       let peekHeight = isPeeking ? peekHeight : 36
       //      let newHeight = peekHeight * heightRatio
       HStack(alignment: .center) {
        handle { isPeeking && showsArrow ? .bottom : .center }
        .foregroundColor(.secondaryLabel)
        .opacity(state.isFocused ? 0.5625 : 1)
        .contentShape(contentShape)
       }
       .frame(height: peekHeight)
       .contentShape(Rectangle())
       // .impact(onChange: state.isFocused, \.soft)
      }
     )
    }
   }
   .offset(y: projectedOffset)
   .opacity(opacity)
   .gesture(gesture, including: dragDisabled ? .none : .all)
  // #if os(iOS)
  // .ignoresSafeArea(ignoresKeyboard ? [.container, .keyboard] : .container)
  // #endif
   .onChange(of: isPresented, perform: update)
   .zIndex(1)
   .ignoresSafeArea(.keyboard)
   //.ignoresSafeArea()
//#if os(iOS)
//   .ignoresSafeArea(
//    .all.subtracting(ignoresKeyboard ? .empty : .keyboard),
//    edges: .all
//   )
//#endif
 }
 
 func update(_ newValue: Bool) {
  if newValue {
   withAnimation(animation) { offset = 0 }
  } else {
#if os(iOS)
   if dismissKeyboard {
    dismissKeyboard()
   }
#endif
   perform?()
   withAnimation(animation) { offset = projectedHeight }
  }
 }
 
 func onChanged(_ action: DragGesture.Value) {
  let newOffset = action.translation.height * 0.5625
  let minThreshold = minThreshold / (isPresented ? 2 : 1)
  let reducedOffset =
  isMinimizing ? newOffset :
  isPeeking ? newOffset : newOffset + (newOffset / minThreshold)
  guard
   isPeeking ?
    reducedOffset > minTranslation :
     reducedOffset > 0 ? reducedOffset < maxTranslation :
     reducedOffset > minThreshold else { return }
  offset = reducedOffset
 }
 
 func onEnded(_ action: DragGesture.Value) {
  let newOffset = action.predictedEndTranslation.height
  let maxOffset = threshold * 2.5
  if newOffset >= maxOffset {
   update(isPresented)
   withAnimation(animation) { isPresented = false }
  } else {
   if isPresented {
    if newOffset < -maxOffset { pullAction?() }
    else if newOffset > threshold / 2.5 { nudgeAction?() }
   } else if newOffset <= -maxOffset {
    withAnimation(animation) { isPresented = true }
   }
   update(isPresented)
  }
 }
 
 init(
  isPresented: Binding<Bool>,
  perform: (() -> ())? = .none,
  pullAction: (() -> ())? = .none,
  nudgeAction: (() -> ())? = .none,
  proxy: Binding<ModalProxy?> = .constant(.none),
  animation: Animation = .modal,
  pullFactor: CGFloat = 0.25,
  dragDisabled: Bool = false,
  showsHandle: Bool = true,
  ignoresKeyboard: Bool = false,
  dismissKeyboard: Bool = false,
  idealHeight: CGFloat? = .none,
  peekDistance: CGFloat? = .none,
  peeksTransparently: Bool = false,
  showsArrow: Bool = true,
  adjustedOffset: CGFloat = .insets.bottom,
  opacity: CGFloat = 1,
  background: (() -> (Background))? = .none,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .shadow,
  shadowRadius: CGFloat = 32,
  shadowOffset: CGSize = .zero,
  @ViewBuilder content: @escaping () -> Content
 ) {
  _isPresented = isPresented
  _proxy = proxy
  self.animation = animation
  self.pullFactor = pullFactor
  self.perform = perform
  self.pullAction = pullAction
  self.nudgeAction = nudgeAction
  self.dragDisabled = dragDisabled
  self.showsHandle = showsHandle
  self.ignoresKeyboard = ignoresKeyboard
  self.dismissKeyboard = dismissKeyboard
  self.idealHeight = idealHeight
  self.peekDistance = peekDistance
  self.peeksTransparently = peeksTransparently
  self.showsArrow = showsArrow
  self.opacity = opacity
  self.background = background
  self.cornerRadius = cornerRadius
  self.shadowColor = shadowColor
  self.shadowRadius = shadowRadius
  self.shadowOffset = shadowOffset
  self.content = content
  self.adjustedOffset = adjustedOffset
 }
}

@available(macOS 11.0, *)
public extension Modal where Background == Color {
 init(
  isPresented: Binding<Bool>,
  perform: (() -> ())? = .none,
  pullAction: (() -> ())? = .none,
  nudgeAction: (() -> ())? = .none,
  proxy: Binding<ModalProxy?> = .constant(.none),
  animation: Animation = .modal,
  pullFactor: CGFloat = 0.25,
  dragDisabled: Bool = false,
  showsHandle: Bool = true,
  ignoresKeyboard: Bool = false,
  dismissKeyboard: Bool = false,
  idealHeight: CGFloat? = .none,
  peekDistance: CGFloat? = .none,
  peeksTransparently: Bool = false,
  showsArrow: Bool = true,
  adjustedOffset: CGFloat = .insets.bottom,
  opacity: CGFloat = 1,
  backgroundColor: Color = .background,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .shadow,
  shadowRadius: CGFloat = 32,
  shadowOffset: CGSize = .zero,
  @ViewBuilder content: @escaping () -> Content
 ) {
  self.init(
   isPresented: isPresented,
   perform: perform,
   pullAction: pullAction,
   nudgeAction: nudgeAction,
   proxy: proxy,
   animation: animation,
   pullFactor: pullFactor,
   dragDisabled: dragDisabled,
   showsHandle: showsHandle,
   ignoresKeyboard: ignoresKeyboard,
   dismissKeyboard: dismissKeyboard,
   idealHeight: idealHeight,
   peekDistance: peekDistance,
   peeksTransparently: peeksTransparently,
   showsArrow: showsArrow,
   adjustedOffset: adjustedOffset,
   opacity: opacity,
   background: { backgroundColor },
   cornerRadius: cornerRadius,
   shadowColor: shadowColor,
   shadowRadius: shadowRadius,
   shadowOffset: shadowOffset,
   content: content
  )
 }
}

@available(macOS 11.0, *)
public extension View {
 @ViewBuilder func modal<Content, Background>(
  isPresented: Binding<Bool>,
  onDismiss perform: (() -> ())? = .none,
  onPull: (() -> ())? = .none,
  onNudge: (() -> ())? = .none,
  onTap: (() -> ())? = .none,
  proxy: Binding<ModalProxy?> = .constant(.none),
  animation: Animation = .modal,
  pullFactor: CGFloat = 0.25,
  dragDisabled: Bool = false,
  showsHandle: Bool = true,
  ignoresKeyboard: Bool = false,
  dismissKeyboard: Bool = false,
  idealHeight: CGFloat? = .none,
  peekDistance: CGFloat? = .none,
  peeksTransparently: Bool = false,
  shadeSubview: Bool = false,
  swipeSubview: Bool = false,
  scaleSubview: Bool = false,
  showsArrow: Bool = true,
  adjustedOffset: CGFloat = .insets.bottom,
  opacity: CGFloat = 1,
  background: (() -> (Background))? = .none,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .shadow,
  shadowRadius: CGFloat = 32,
  shadowOffset: CGSize = .zero,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View, Background: View {
  modifier(
   ModalModifier(
    modal:
     Modal<Content, Background>(
      isPresented: isPresented,
      perform: perform,
      pullAction: onPull,
      nudgeAction: onNudge,
      proxy: proxy,
      animation: animation,
      pullFactor: pullFactor,
      dragDisabled: dragDisabled,
      showsHandle: showsHandle,
      ignoresKeyboard: ignoresKeyboard,
      dismissKeyboard: dismissKeyboard,
      idealHeight: idealHeight,
      peekDistance: peekDistance,
      peeksTransparently: peeksTransparently,
      showsArrow: showsArrow,
      adjustedOffset: adjustedOffset,
      opacity: opacity,
      background: background,
      cornerRadius: cornerRadius,
      shadowColor: shadowColor,
      shadowRadius: shadowRadius,
      shadowOffset: shadowOffset,
      content: content
     ),
    action: onTap,
    shadeSubview: shadeSubview,
    swipeSubview: swipeSubview,
    scaleSubview: scaleSubview
   )
  )
 }
 
 @ViewBuilder func modal<Content>(
  isPresented: Binding<Bool>,
  onDismiss perform: (() -> ())? = .none,
  onPull: (() -> ())? = .none,
  onNudge: (() -> ())? = .none,
  onTap: (() -> ())? = .none,
  proxy: Binding<ModalProxy?> = .constant(.none),
  animation: Animation = .modal,
  pullFactor: CGFloat = 0.25,
  dragDisabled: Bool = false,
  showsHandle: Bool = true,
  ignoresKeyboard: Bool = false,
  dismissKeyboard: Bool = false,
  idealHeight: CGFloat? = .none,
  peekDistance: CGFloat? = .none,
  peeksTransparently: Bool = false,
  shadeSubview: Bool = false,
  swipeSubview: Bool = false,
  scaleSubview: Bool = false,
  showsArrow: Bool = true,
  adjustedOffset: CGFloat = .insets.bottom,
  opacity: CGFloat = 1,
  backgroundColor: Color = .background,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .shadow,
  shadowRadius: CGFloat = 32,
  shadowOffset: CGSize = .zero,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View {
  modal(
   isPresented: isPresented,
   onDismiss: perform,
   onPull: onPull,
   onNudge: onNudge,
   onTap: onTap,
   proxy: proxy,
   animation: animation,
   pullFactor: pullFactor,
   dragDisabled: dragDisabled,
   showsHandle: showsHandle,
   ignoresKeyboard: ignoresKeyboard,
   dismissKeyboard: dismissKeyboard,
   idealHeight: idealHeight,
   peekDistance: peekDistance,
   peeksTransparently: peeksTransparently,
   shadeSubview: shadeSubview,
   swipeSubview: swipeSubview,
   scaleSubview: scaleSubview,
   showsArrow: showsArrow,
   adjustedOffset: adjustedOffset,
   opacity: opacity,
   background: { backgroundColor },
   cornerRadius: cornerRadius,
   shadowColor: shadowColor,
   shadowRadius: shadowRadius,
   shadowOffset: shadowOffset,
   content: content
  )
 }
}

public struct ModalProxy {
 public var offset: CGFloat,
            translation: CGFloat,
            minOffset: CGFloat,
            maxOffset: CGFloat,
            projectedHeight: CGFloat,
            projectedOffset: CGFloat,
            maxHeight: CGFloat,
            contentHeight: CGFloat,
            peekHeight: CGFloat,
            negativeHeight: CGFloat,
            positiveHeight: CGFloat,
            threshold: CGFloat,
            negativeOffsetDegree: CGFloat,
            positiveOffsetDegree: CGFloat,
            negativeThresholdDegree: CGFloat,
            positiveThresholdDegree: CGFloat,
            thresholdOffsetDegree: CGFloat,
            thresholdTranslationDegree: CGFloat,
            isMinimizing: Bool,
            isPeeking: Bool,
            peekDegree: CGFloat,
            gesture: _EndedGesture<_ChangedGesture<DragGesture>>
 init<A: View, B: View>(from modal: Modal<A, B>) {
  offset = modal.offset
  minOffset = modal.minOffset
  maxOffset = modal.maxOffset
  translation = modal.translation
  projectedHeight = modal.projectedHeight
  projectedOffset = modal.projectedOffset
  maxHeight = modal.maxHeight
  contentHeight = modal.contentHeight
  peekHeight = modal.peekHeight
  negativeHeight = modal.negativeHeight
  positiveHeight = modal.positiveHeight
  threshold = modal.threshold
  negativeOffsetDegree = modal.negativeOffsetDegree
  positiveOffsetDegree = modal.positiveOffsetDegree
  negativeThresholdDegree = modal.negativeThresholdDegree
  positiveThresholdDegree = modal.positiveThresholdDegree
  thresholdOffsetDegree = modal.thresholdOffsetDegree
  thresholdTranslationDegree = modal.thresholdTranslationDegree
  isMinimizing = modal.isMinimizing
  isPeeking = modal.isPeeking
  peekDegree = modal.peekDegree
  gesture = modal.gesture
 }
}

struct ModalModifier<ModalContent: View, ModalBackground: View>: ViewModifier {
 let modal: Modal<ModalContent, ModalBackground>
 var proxy: ModalProxy? { modal.proxy }
 var isPresented: Bool { modal.isPresented }
 let action: (() -> ())?
 let shadeSubview: Bool
 let swipeSubview: Bool
 let scaleSubview: Bool
 @ViewBuilder func body(content: Content) -> some View {
  let gestureContent =
  Group {
   if swipeSubview, let proxy = proxy {
    content.gesture(proxy.gesture, including: .all)
   } else {
    content
   }
  }
  Group {
   if scaleSubview, let proxy = proxy {
    let topInset: CGFloat = (CGFloat.insets.top > 0 ? .insets.top : 22)
    let minFraction = (proxy.projectedHeight - topInset) / proxy.projectedHeight
    let degree = isPresented ? proxy.negativeOffsetDegree : 0
    let fraction: CGFloat = 1 - degree
    let reducedFraction = max(minFraction, fraction)
    // let cornerRadius = 8 * (1 - fraction)
    gestureContent
    // .cornerRadius(cornerRadius)
     .scaleEffect(reducedFraction, anchor: .bottom)
     .backgroundColor(.black)
   } else {
    gestureContent
   }
  }
  .overlay {
   if shadeSubview, let proxy = proxy {
    Color.black.opacity(
     (isPresented ? 0.5 : 0) +
     proxy.negativeOffsetDegree - proxy.positiveOffsetDegree
    )
   }
  }
  .onTapGesture { action?() }
  .zIndex(0)
  .overlay(modal, alignment: .bottom)
 }
}
