import SwiftUI

// TODO: Add item views
/// An evenly stacked toolbar.
@available(macOS 11.0, *)
public struct Toolbar<Content, Background: View>: View where Content: View {
 let position: Edge
 let height: CGFloat
 let padding: CGFloat
 let spacing: CGFloat?
 let alignment: HorizontalAlignment
 let insets: EdgeInsets
 let background: Background
 let showBorder: Bool
 let isVisible: Bool
 let transition: AnyTransition
 @ViewBuilder var content: () -> Content
 public var body: some View {
  HStack(alignment: .center, spacing: spacing) {
   content().lineLimit(1)
  }
  .inset(.standard, padding)
  .insets(insets)
  .frame(
   maxWidth: .infinity,
   alignment: Alignment(horizontal: alignment, vertical: .center)
  )
  .frame(idealHeight: height)
  .background(background)
  .overlay(position == .top ? .bottom : .top) {
   if showBorder { Divider() }
  }
  .visibility(isVisible)
  .transition(transition)
  .ignoresSafeArea(.container, edges: Edge.Set(position))
 }
}

@available(macOS 11.0, *)
public extension Toolbar {
 init(
  _ position: Edge = .top,
  height: CGFloat,
  padding: CGFloat,
  spacing: CGFloat?,
  alignment: HorizontalAlignment = .leading,
  insets: EdgeInsets,
  background: Background,
  showBorder: Bool = false,
  isVisible: Bool = true,
  transition: AnyTransition = .identity,
  @ViewBuilder content: @escaping () -> Content
 ) {
  self.position = position
  self.height = height
  self.padding = padding
  self.spacing = spacing
  self.alignment = alignment
  self.insets = insets
  self.background = background
  self.showBorder = showBorder
  self.content = content
  self.isVisible = isVisible
  self.transition = transition
 }
}

@available(macOS 11.0, *)
public struct ToolbarModifier<ToolbarContent, Background: View>: ViewModifier
where ToolbarContent: View {
 @ViewBuilder var toolbarContent: () -> ToolbarContent
 var position: Edge = .top
 let height: CGFloat
 let offset: CGFloat
 let insets: EdgeInsets
 let padding: CGFloat
 let spacing: CGFloat?
 var alignment: HorizontalAlignment = .leading
 let background: Background
 var showBorder: Bool = false
 let isOverlay: Bool
 let isVisible: Bool
 let transition: AnyTransition
 public func body(content: Content) -> some View {
  let height = isVisible ? height : 0
  let toolbar =
   Toolbar(
    position,
    height: height,
    padding: padding,
    spacing: spacing,
    alignment: alignment,
    insets: insets,
    background: background,
    showBorder: showBorder,
    isVisible: isVisible,
    transition: transition,
    content: toolbarContent
   )
   .offset(y: offset)
  let isTop = position == .top
  Group {
   if isOverlay {
    content
     .insetScrollView(Edge.Set(position), height)
     //.padding(isTop ? .top : .bottom, height)
     .overlay(isTop ? .top : .bottom) { toolbar }
   } else {
    VStack(spacing: 0) {
     if isTop {
      toolbar
      content
     } else {
      content
      toolbar
     }
    }
   }
  }
  .ignoresSafeArea(.container, edges: Edge.Set(position))
 }
}

@available(macOS 11.0, *)
public extension View {
 // Custom background
 func customToolbar<Content, Background: View>(
  _ position: Edge = .top,
  height: CGFloat = 48,
  padding: CGFloat = 8.5,
  spacing: CGFloat? = .none,
  alignment: HorizontalAlignment = .leading,
  insets: EdgeInsets = .zero,
  offset: CGFloat = 0,
  background: Background,
  showBorder: Bool = true,
  isOverlay: Bool = false,
  isVisible: Bool = true,
  transition: AnyTransition = .identity,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View {
  modifier(
   ToolbarModifier(
    toolbarContent: content,
    position: position,
    height: height,
    offset: offset,
    insets: insets,
    padding: padding,
    spacing: spacing,
    alignment: alignment,
    background: background,
    showBorder: showBorder,
    isOverlay: isOverlay,
    isVisible: isVisible,
    transition: transition
   )
  )
 }

  // Custom background
 func customToolbar<Content>(
  _ position: Edge = .top,
  height: CGFloat = 48,
  padding: CGFloat = 8.5,
  spacing: CGFloat? = .none,
  alignment: HorizontalAlignment = .leading,
  insets: EdgeInsets = .zero,
  offset: CGFloat = 0,
  backdrop: Backdrop,
  color: Color? = .none,
  style: UIBlurEffect.Style? = .none,
  vibrancy: UIVibrancyEffectStyle? = .none,
  showBorder: Bool = true,
  isOverlay: Bool = false,
  isVisible: Bool = true,
  transition: AnyTransition = .identity,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View {
  modifier(
   ToolbarModifier(
    toolbarContent: content,
    position: position,
    height: height,
    offset: offset,
    insets: insets,
    padding: padding,
    spacing: spacing,
    alignment: alignment,
    background:
     Backdrop(
      color ?? backdrop.color,
      style: style ?? backdrop.style,
      vibrancy: vibrancy ?? backdrop.vibrancy,
      disabled: isOverlay ? .none : true
     ),
    showBorder: showBorder,
    isOverlay: isOverlay,
    isVisible: isVisible,
    transition: transition
   )
  )
 }

 // Colored background
 func customToolbar<Content>(
  _ position: Edge = .top,
  height: CGFloat = 48,
  padding: CGFloat = 8.5,
  spacing: CGFloat? = .none,
  alignment: HorizontalAlignment = .leading,
  insets: EdgeInsets = .zero,
  offset: CGFloat = 0,
  backgroundColor: Color,
  showBorder: Bool = true,
  isOverlay: Bool = false,
  isVisible: Bool = true,
  transition: AnyTransition = .identity,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View {
  customToolbar(
   position,
   height: height,
   padding: padding,
   spacing: spacing,
   alignment: alignment,
   insets: insets,
   offset: offset,
   background:
   Backdrop(
    backgroundColor,
    style: .prominent,
    disabled: !isOverlay
   ),
   showBorder: showBorder,
   isOverlay: isOverlay,
   isVisible: isVisible,
   transition: transition,
   content: content
  )
 }

 // Default background
 func customToolbar<Content>(
  _ position: Edge = .top,
  height: CGFloat = 48,
  padding: CGFloat = 8.5,
  spacing: CGFloat? = .none,
  alignment: HorizontalAlignment = .leading,
  insets: EdgeInsets = .zero,
  offset: CGFloat = 0,
  showBorder: Bool = true,
  isOverlay: Bool = true,
  isVisible: Bool = true,
  transition: AnyTransition = .identity,
  @ViewBuilder content: @escaping () -> Content
 ) -> some View where Content: View {
  customToolbar(
   position,
   height: height,
   padding: padding,
   spacing: spacing,
   alignment: alignment,
   insets: insets,
   offset: offset,
   background:
   Backdrop(
    style: .systemThickMaterial,
    disabled: isOverlay ? .none : true
   ),
   showBorder: showBorder,
   isOverlay: isOverlay,
   isVisible: isVisible,
   transition: transition,
   content: content
  )
 }
}
