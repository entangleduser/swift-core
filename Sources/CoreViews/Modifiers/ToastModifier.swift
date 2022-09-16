import Combine
import SwiftUI
import Colors

@available(macOS 11.0, *)
public struct Toast: View {
 @Environment(\.colorScheme) var colorScheme
 @Binding var result: ToastResult?
 @State var message: String? = .empty
 @State var background: Color? = .clear
 @State var foreground: Color? = .clear
 @State var action: (() -> ())?
 @State var label: String? = .empty
 var position: Position = .top
 var perform: (() -> ())?
 @State var timeout: TimeInterval = 3
 @State var offset: CGFloat = 0
 @State var contentSize: CGSize = .zero
 @State var timer: DispatchSourceTimer?
 let defaultTimeout: TimeInterval
 func start() {
  if timer == nil {
   timer =
    DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
  }
  timer?.setEventHandler {
   if !self.isPressed {
    self.remove()
   }
   self.timer = nil
  }
  timer?.schedule(deadline: .now() + timeout)
  timer?.resume()
 }

 func cancel() {
  timer?.cancel()
  timer = nil
 }

 func restart() {
  cancel()
  start()
 }

 @State var isPressed: Bool = false
 @State var isPresented: Bool = false {
  didSet {
   if !isPresented {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
     contentSize = .zero
     message = .empty
     label = .empty
     foreground = .clear
     background = .clear
    }
   }
  }
 }

 #if os(iOS)
  @State var topInset: CGFloat = .insets.top
 #elseif os(macOS)
  @State var topInset: CGFloat = 0
 #endif

 @State var adjustedOffset: CGFloat = 0
 @State var zIndex: Double = .infinity

 public var body: some View {
  #if os(iOS)
   let blurStyle: UIBlurEffect.Style =
    background == .none ? .systemThickMaterial : .prominent
   let vibrancy: UIVibrancyEffectStyle? =
    background == .none ? .tertiaryFill : .none
  #endif
  let background = background ?? .clear
  let foreground =
   foreground ??
   self.background?.backgroundOverlay(self.background) ?? .label.translucent
  let newOffset =
   isPresented ?
   (position == .bottom ?
    .screen.height - offset : offset - topInset)
   : -contentSize.height
  StateButton(
   action: {
    // Trigger action without label.
    if label == .none, let action = action {
     action()
     remove()
    } else { onEnded(false) }
   },
   onChange: { state in
    if !isPressed {
     if state == .normal {
      onEnded(true)
     } else {
      isPressed = true
     }
    }
   },
   label: { state in
    HStack(alignment: .center, spacing: 0) {
     Text.Optional(message?.wrapped).semibold()
      .inset()
      .transition(.identity)
     // Trigger action with label.
     if let label = label, let action = action {
      StateButton(
       action: {
        action()
        remove()
       },
       label: { state in
        Text.Optional(label.wrapped).bold(.headline)
         .inset()
         .opacity(state.isFocused ? 0.75 : 0.9)
         .transition(.identity)
         .contentShape(Rectangle())
       }
      )
     }
    }
    .frame(maxWidth: .screen.width, alignment: .center)
    .padding(.vertical, 8.5)
    .padding(
     position == .top ? .top : .bottom, (topInset * 1.765) + adjustedOffset
    )
    .padding(.horizontal, 8.5)
    .minimumScaleFactor(0.8)
    .lineLimit(2)
    .multilineTextAlignment(.center)
    .backdrop(
     Backdrop(background, style: blurStyle, vibrancy: vibrancy),
     foreground: foreground,
     shadowColor: background.shadow.subtle,
     shadowRadius: 3.5,
     shadowY: 1.5
    )
    .overlay(
     Divider().foregroundColor(foreground.highlight), alignment: .bottom
    )
    .overlay(
     Divider()
      .foregroundColor(foreground.shadow)
      .opacity(colorScheme == .dark ? 1 : 0.05),
     alignment: .bottom
    )
    .gesture(
     DragGesture(minimumDistance: 0.001, coordinateSpace: .global)
      .onChanged { gesture in
       let translation = gesture.translation.height
       if !isPressed { withAnimation(.toast) { isPressed = true } }
       guard (lowerBound ... 0).contains(translation) else { return }
       withAnimation(.toast) { offset = translation }
      }
      .onEnded { gesture in
       guard gesture.predictedEndLocation.y > 0 else {
        remove(with: .toast.speed(0.865))
        return
       }
       onEnded(true)
      }
    )
    .impact(isPressed, \.soft, intensity: 0.75)
    .opacity(isPressed ? 0.9 : 1)
   }
  )
  .frame(maxWidth: .infinity)
  .readSize($contentSize)
  .offset(y: newOffset)
  .visibility(contentSize != .zero)
  .transition(.slide)
  .zIndex(zIndex)
  #if os(iOS)
   .ignoresSafeArea(edges: position.edges)
  #endif
  .onChange(of: result, perform: update)
 }

 var lowerBound: CGFloat { position == .top ? -11.5 : 11.5 }

 func update(with result: ToastResult?) {
  timeout = result?.timeout ?? defaultTimeout
  restart()
  guard let result = result else {
   if isPresented { remove() }
   return
  }
  DispatchQueue.main.async {
   withAnimation(.linear(duration: 0.5)) {
    background = result.background
    foreground = result.foreground
   }
   self.action = result.action
   withAnimation(.toast) {
    if !isPresented {
     // visibility = true
     isPresented = true
    }
    message = result.text
    label = result.label
   }
  }
 }

 func resetValues(
  animate: Bool = true,
  with animation: Animation = .toast
 ) {
  withAnimation(animate ? animation : .none) {
   isPresented = false
   result = .none
   action = .none
  }
  onEnded(animate: false)
 }

 func onEnded(
  _ shouldRestart: Bool = false,
  animate: Bool = true,
  with animation: Animation = .toast
 ) {
  if shouldRestart { restart() }
  withAnimation(animate ? animation : .none) {
   isPressed = false
   offset = 0
  }
 }

 func remove(
  animate: Bool = true,
  with animation: Animation = .toast
 ) {
  DispatchQueue.main.async {
   perform?()
   self.cancel()
   resetValues(animate: animate, with: animation)
  }
 }

 init(
  result: Binding<ToastResult?>,
  message: String? = .none,
  background: Color? = .none,
  foreground: Color? = .none,
  position: Position? = .none,
  topInset: CGFloat? = .none,
  adjustedOffset: CGFloat? = .none,
  zIndex: Double? = .none,
  perform: (() -> ())? = .none,
  timeout: TimeInterval = 3
 ) {
  _result = result
  defaultTimeout = timeout
  self.background = background
  self.foreground = foreground
  if let position = position {
   self.position = position
  }
  if let topInset = topInset {
   self.topInset = topInset
  }
  if let adjustedOffset = adjustedOffset {
   self.adjustedOffset = adjustedOffset
  }
  if let zIndex = zIndex {
   self.zIndex = zIndex
  }
  self.perform = perform
  self.message = message
 }
}

public indirect enum ToastResult:
Identifiable, Equatable, ExpressibleByStringLiteral {
 case
  `default`(String, TimeInterval? = nil),
  destructive(String, TimeInterval? = nil),
  result(Result<String, Error>, TimeInterval? = nil),
  custom(
   String,
   _ background: Color? = nil, foreground: Color? = nil, TimeInterval? = nil
  ),
  action(_ result: ToastResult, _ label: String? = nil, _ action: () -> ())
 public init(stringLiteral message: String) {
  self = .default(message)
 }

 public func action(
  _ label: String?, _ perform: @escaping () -> ()
 ) -> ToastResult {
  .action(self, label, perform)
 }
 
 public static func failure(
  _ error: Error, timeout: TimeInterval? = nil
 ) -> ToastResult {
  .result(.failure(error), timeout)
 }
 
 public static func success(
  _ message: String, timeout: TimeInterval? = nil
 ) -> ToastResult {
  .result(.success(message), timeout)
 }

 public var id: Int {
  text.hashValue + (background?.hashValue ?? 0) + (foreground?.hashValue ?? 0)
 }

 public var timeout: TimeInterval? {
  switch self {
  case let .destructive(_, timeout): return timeout
  case let .result(_, timeout): return timeout
  case let .default(_, timeout): return timeout
  case let .custom(_, _, _, timeout): return timeout
  case let .action(result, _, _): return result.timeout
  }
 }

 public var action: (() -> ())? {
  switch self {
  case let .action(_, _, action): return action
  default: return .none
  }
 }

 public var label: String? {
  switch self {
  case let .action(_, label, _): return label
  default: return .none
  }
 }

 public var text: String {
  switch self {
  case let .destructive(message, _): return message
  case let .result(result, _):
   switch result {
   case let .failure(error): return error.message
   case let .success(message): return message
   }
  case let .default(message, _): return message
  case let .custom(message, _, _, _): return message
  case let .action(result, _, _): return result.text
  }
 }

 public var background: Color? {
  switch self {
  case .destructive:
   return .red.luminosity(0.53)
  case let .result(result, _):
   switch result {
   case .failure: return .red.luminosity(0.53)
   case .success: return .green.luminosity(0.4)
   }
  case let .custom(_, background, _, _): return background
  case let .action(result, _, _): return result.background
  default: return .none
  }
 }

 public var foreground: Color? {
  switch self {
  case let .custom(_, _, foreground, _): return foreground
  case let .action(result, _, _): return result.foreground
  default: return .none
  }
 }

 public static func == (lhs: ToastResult, rhs: ToastResult) -> Bool {
  lhs.text == rhs.text
   && lhs.background == rhs.background
   && lhs.foreground == rhs.foreground
 }
}

struct ToastModifier: ViewModifier {
 @Binding var result: ToastResult?
 let position: Position?
 let topInset: CGFloat?
 let adjustedOffset: CGFloat?
 let zIndex: Double?
 let perform: (() -> ())?
 let timeout: TimeInterval
 let isVisible: Bool
 public func body(content: Content) -> some View {
  content
   .overlay(
    Toast(
     result: $result,
     position: position,
     topInset: topInset,
     adjustedOffset: adjustedOffset,
     zIndex: zIndex,
     perform: perform,
     timeout: timeout
    )
    .offset(y: adjustedOffset ?? 0)
    .visibility(isVisible),
    alignment: position?.alignment ?? .top
   )
 }
}

@available(macOS 11.0, *)
public extension View {
 @ViewBuilder func toast(
  result: Binding<ToastResult?>,
  position: Position? = .none,
  topInset: CGFloat? = .none,
  adjustedOffset: CGFloat? = .none,
  zIndex: Double? = .none,
  onDismiss perform: (() -> ())? = .none,
  timeout: TimeInterval = 3,
  isVisible: Bool = true
 ) -> some View {
  modifier(
   ToastModifier(
    result: result,
    position: position,
    topInset: topInset,
    adjustedOffset: adjustedOffset,
    zIndex: zIndex,
    perform: perform,
    timeout: timeout,
    isVisible: isVisible
   )
  )
 }
}
