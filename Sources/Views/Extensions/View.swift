import Introspect
import SwiftUI
import Storage

#if os(iOS)
 public typealias NativeView = UIView
 public typealias HostingController = UIHostingController
 public typealias ViewRepresentable = UIViewRepresentable
 public typealias NativeFont = UIFont
#elseif os(macOS)
 public typealias NativeView = NSView
 public typealias HostingController = NSHostingController
 public typealias ViewRepresentable = NSViewRepresentable
 public typealias NativeFont = NSFont
#endif


@available(macOS 11.0, *)
public extension View {
 @_disfavoredOverload func background<Content: View>(
  _ alignment: Alignment = .center,
  @ViewBuilder _ content: () -> Content
 ) -> some View {
  background(content(), alignment: alignment)
 }

 @_disfavoredOverload func overlay<Content: View>(
  _ alignment: Alignment = .center,
  @ViewBuilder _ content: () -> Content
 ) -> some View {
  overlay(content(), alignment: alignment)
 }

 func color(_ newValue: Color) -> some View {
  foregroundColor(newValue)
 }

 func accent(_ keyPath: KeyPath<Color, Color> = \.self) -> some View {
   foregroundColor(.defaultColor[keyPath: keyPath])
 }

 func backgroundColor(_ color: Color) -> some View {
  background(color)
 }

 func outline(
  color: Color = .separator,
  corners: CornerSet = .all,
  cornerRadius: CGFloat = 0,
  width: CGFloat = 0.75
 ) -> some View {
  overlay(
   RoundedPath(radius: cornerRadius, corners: corners)
    .stroke(color, lineWidth: width)
  )
 }

 #if os(iOS)
  func dismissKeyboard() {
   UIApplication.shared.sendAction(
    #selector(
     UIApplication.resignFirstResponder
    ), to: nil, from: nil, for: nil
   )
  }
 #endif
 func assignNextResponder() {
  #if os(iOS)
   while let next = UIApplication.shared.next, next.canBecomeFirstResponder {
    next.becomeFirstResponder()
    break
   }
  #elseif os(macOS)
   NSApplication.shared.nextResponder?.becomeFirstResponder()
  #endif
 }
}

public extension View {
 func fixedFrame(
  _ size: CGFloat, alignment: Alignment = .leading
 ) -> some View {
  frame(width: size, height: size, alignment: alignment)
 }
 func fixedFrame(
  _ size: CGSize, alignment: Alignment = .leading
 ) -> some View {
  frame(width: size.width, height: size.height, alignment: alignment)
 }

 func maxFrame(align: Alignment = .topLeading) -> some View {
  frame(maxHeight: .infinity)
   .frame(maxWidth: .infinity, alignment: align)
 }

 func perform(action: @escaping () -> ()) -> Self {
  action()
  return self
 }

 func async(
  delay: DispatchTime = .now(),
  action: @escaping () -> ()
 ) -> Self {
  perform {
   DispatchQueue.main.asyncAfter(deadline: delay) {
    action()
   }
  }
 }
}

@available(macOS 11.0, *)
public extension View {
 @ViewBuilder func insetTableView(
  _ edges: Edge.Set = .top, _ offset: CGFloat,
  insetsContent: Bool = true,
  insetsScrollbar: Bool = true,
  bounces: Bool = true,
  scrollIndicatorInsets: NativeEdgeInsets? = nil,
  setSafeArea: Bool = false,
  ignores: SafeAreaRegions = .container
 ) -> some View {
  let inset = NativeEdgeInsets(edges, offset)
  safeAreaInsets(
   setSafeArea ? edges : .empty,
   offset,
   ignores: ignores,
   system: false
  )
  .introspectTableView {
   #if os(iOS)
//    if setSafeArea, let controller = $0.inputViewController {
//     controller.additionalSafeAreaInsets = inset
//    }
    if insetsContent {
     $0.contentInset = inset
     if insetsScrollbar {
      $0.scrollIndicatorInsets =
       insetsScrollbar ? scrollIndicatorInsets ?? inset : .zero
      $0.verticalScrollIndicatorInsets =
       insetsScrollbar ? scrollIndicatorInsets ?? inset : .zero
      $0.automaticallyAdjustsScrollIndicatorInsets = true
      $0.bounces = bounces
     }
    }
   #elseif os(macOS) // TODO: Implement
   #endif
  }
 }

 @ViewBuilder func insetScrollView(
  _ edges: Edge.Set = .top, _ offset: CGFloat,
  insetsContent: Bool = true,
  insetsScrollbar: Bool = true,
  bounces: Bool = true,
  scrollIndicatorInsets: NativeEdgeInsets? = nil,
  setSafeArea: Bool = false
 ) -> some View {
  introspectScrollView {
   let inset = $0.adjustedContentInset.adding(edges, offset)
   #if os(iOS)
    if setSafeArea, let controller = $0.inputViewController {
     controller.additionalSafeAreaInsets = inset
    }
    if insetsContent {
     
     $0.contentInset = inset
     if insetsScrollbar {
      $0.scrollIndicatorInsets =
       insetsScrollbar ? scrollIndicatorInsets ?? inset : .zero
      $0.verticalScrollIndicatorInsets =
       insetsScrollbar ? scrollIndicatorInsets ?? inset : .zero
      $0.automaticallyAdjustsScrollIndicatorInsets = true
      $0.bounces = bounces
     }
    }
   #elseif os(macOS) // TODO: Implement
   #endif
  }
 }

 @ViewBuilder func safeAreaInsets(
  _ edges: Edge.Set = .top,
  _ offset: CGFloat,
  ignores: SafeAreaRegions = .all,
  system: Bool = true
 ) -> some View {
  frame(maxWidth: .infinity, maxHeight: .infinity)
   .ignoresSafeArea(ignores, edges: edges)
   .introspectViewController {
    $0.additionalSafeAreaInsets = .additional(edges, offset)
   }
   ._safeAreaInsets(system ? .system(edges, offset) : .device)
 }

 var navigationArrow: some View {
  Image(systemName: "chevron.right")
   .resizable()
   .bold()
   .frame(width: 7, height: 11.5)
   .foregroundColor(.tertiaryLabel)
 }

 func handle(
  _ position: @escaping () -> Position = { .center }
 ) -> some View {
  Image(
   systemName: {
    switch position() {
    case .bottom: return "chevron.compact.up"
    case .top: return "chevron.compact.down"
    default: return "minus"
    }
   }()
  )
  .inset(.standard)
  .font(.custom(.empty, size: 47, relativeTo: .body))
 }

 func separator(
  _ color: Color = .separator,
  lineWidth: CGFloat = 1,
  dash: [CGFloat] = []
 ) -> some View {
  overlay(
   GeometryReader { proxy in
    Path { path in
     path.move(
      to:
      CGPoint(
       x: proxy.frame(in: .global).minX,
       y: proxy.frame(in: .local).minY + proxy.frame(in: .local).size.height
      )
     )
     path.addLine(
      to:
      CGPoint(
       x: proxy.frame(in: .global).maxX,
       y: proxy.frame(in: .local).minY + proxy.frame(in: .local).size.height
      )
     )
    }
    .stroke(
     color,
     style: StrokeStyle(lineWidth: lineWidth, dash: dash)
    )
   }
  )
 }
}

// public extension View {
// unowned var settings: Settings { .shared }
// }
//
// public extension App {
// unowned var settings: Settings { .shared }
// }
//
// public extension ViewModifier {
// unowned var settings: Settings { .shared }
// }
