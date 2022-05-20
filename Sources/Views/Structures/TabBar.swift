import SwiftUI
import Core
import Storage
import OrderedCollections
import Colors

@available(macOS 11.0, *)
public struct TabBar: View {
 typealias Storage = TabBarStorage
 typealias Style = BackdropForeground
 internal init?(
  tag: Binding<Int>,
  height: CGFloat,
  inset: CGFloat,
  padding: CGFloat,
  bottomPadding: CGFloat,
  spacing: CGFloat?,
  style: Style,
  corners: CornerSet,
  cornerRadius: CGFloat,
  outlineColor: Color,
  shadowColor: Color,
  shadowRadius: CGFloat,
  shadowOffset: CGSize,
  offset: CGFloat,
  x: CGFloat, y: CGFloat,
  transition: AnyTransition,
  animation: Animation?,
  content: @escaping (_ selected: Bool, _ state: Control.State) -> TabBarContent
 ) {
  let defaultContent = content(false, .normal)
  guard defaultContent.notEmpty else { return nil }
  if Storage.shared.content.isEmpty {
   Storage.shared.content = defaultContent
  }
  _tag = tag
  self.content = content
  self.height = height
  self.inset = inset
  self.padding = padding
  self.bottomPadding = bottomPadding
  self.spacing = spacing
  self.style = style
  self.corners = corners
  self.cornerRadius = cornerRadius
  self.outlineColor = outlineColor
  self.shadowColor = shadowColor
  self.shadowRadius = shadowRadius
  self.shadowOffset = shadowOffset
  self.offset = offset
  self.x = x
  self.y = y
  self.transition = transition
  self.animation = animation
  defer { self.tag = tag.wrappedValue }
 }

 @Environment(\.colorScheme) var colorScheme

 @Binding private var tag: Int {
  didSet {
   lastTag = oldValue
   usedTags.insert(oldValue)
  }
 }

 let content: (Bool, Control.State) -> TabBarContent
 let height: CGFloat
 let inset: CGFloat
 let padding: CGFloat
 let bottomPadding: CGFloat
 let spacing: CGFloat?
 let style: Style
 let corners: CornerSet
 let cornerRadius: CGFloat
 let outlineColor: Color
 let shadowColor: Color
 let shadowRadius: CGFloat
 let shadowOffset: CGSize
 let offset: CGFloat
 let x: CGFloat
 let y: CGFloat
 let transition: AnyTransition
 let animation: Animation?

 var views: [AnyView] { Storage.shared.content.map(\.0) }
 var lastTag: Int? {
  get { Storage.shared.lastTag }
  nonmutating set { Storage.shared.lastTag = newValue }
 }

 var usedTags: Set<Int> {
  get { Storage.shared.usedTags }
  nonmutating set { Storage.shared.usedTags = newValue }
 }

 var count: Int { Storage.shared.content.count }
 var range: Range<Int> { 0 ..< count }

 var tabWidth: CGFloat { .screen.width / CGFloat(count) // + adjustedInset
 }

 private var outlinePadding: CGFloat { 0.5 }
 private var compensatedOutlinePadding: CGFloat { outlinePadding * 2 }
 private var adjustedInset: CGFloat { inset * 2 }
 private var compensatedInset: CGFloat {
  adjustedInset < 0 ? -adjustedInset : adjustedInset
 }

 private var projectedWidth: CGFloat {
  contentSize.width + compensatedInset + (outlinePadding * 1.15)
 }

 private var projectedHeight: CGFloat {
  height + (padding / 2)
 }

 private var projectedOffset: CGFloat { offset }

 private var contentInset: CGFloat { projectedHeight + projectedOffset }
 private var projectedContentInset: CGFloat { contentInset * 1.5 }
 @State var contentSize: CGSize = .zero
 var tabBar: some View {
  HStack(alignment: .center, spacing: spacing) {
   Spacer()
   ForEach(range, id: \.self) { int in
    StateButton(
     action: {
      dismissKeyboard()
      withAnimation(animation) { tag = int }
     },
     label: { state in
      let selected = tag == int
      let highlighted = selected && lastTag == tag
      let state = highlighted ? state.union(.highlighted) : state
      let item = content(selected, state).map(\.1)[int]
      item
       // .border(.green)
       .foregroundColor(
        selected ? .accentColor : .secondary
       )
        .frame(
         maxWidth: tabWidth + (padding * 2),
         maxHeight: .infinity,
         alignment: .center
        )
        .padding(padding)
        .padding(.bottom, bottomPadding)
        .contentShape(Rectangle())
      // .offset(y: outlinePadding)
//       .impact(
//        item.perform == nil ? false : state.isHighlightedAndFocused, \.soft,
//        intensity: 0.8, perform: item.perform
//       )
     }
    )
   }
   .offset(y: offset)
   #if DEBUG
    .border(.green)
   #endif
   Spacer()
  }
  .frame(maxWidth: projectedWidth, maxHeight: projectedHeight)
  #if DEBUG
   .border(.purple)
  #endif
  
  .backdrop(
   style,
   inline: style.backdrop == .clear ? Color.clear : outlineColor,
   outline:
    style.backdrop == .clear ? Color.clear :
    Color.background.light.opacity(colorScheme == .dark ? 1 : 0.5),
   // padding: inset,
   cornerRadius: cornerRadius,
   corners: corners,
   y: outlinePadding
  )
  .shadow(
   color: shadowColor,
   radius: shadowRadius,
   x: shadowOffset.width,
   y: shadowOffset.height
  )
  .ignoresSafeArea()
 }

 var placeholderView: some View { AnyView(Color.clear.fixedFrame(contentSize)) }
 public var body: some View {
//  TabView(selection: $tag) {
  HStack(spacing: 0) {
   ForEach(range, id: \.self) { int in
    if usedTags.contains(int) {
     views[int].readSize($contentSize)
    } else {
     Color.clear
    }
   }
//  }
//  .tabViewStyle(.page(indexDisplayMode: .never))
   .ignoresSafeArea(.container)
   .frame(width: .screen.width)
   .offset(x: .screen.width)
   .insetTableView(
    .bottom, contentInset,
    insetsContent: false,
    setSafeArea: true
   )
   #if DEBUG
    .border(.orange)
   #endif
  }
  .offset(x: .screen.width * -CGFloat(tag))
  .overlay(
   tabBar
    .position(
     x: .screen.width * 1.5,
     y: .screen.height - (projectedHeight / 2)
    ),
   alignment: .bottom
  )
 }
}

@available(macOS 11.0, *)
public extension TabBar {
 init?(
  _ tag: Binding<Int>,
  height: CGFloat = 49,
  inset: CGFloat = 0,
  padding: CGFloat = 8.5,
  bottomPadding: CGFloat = 0,
  spacing: CGFloat? = 0,
  style: BackdropForeground? = .chrome,
  corners: CornerSet = .none,
  cornerRadius: CGFloat = 15,
  outlineColor: Color? = .none,
  shadowColor: Color? = .none,
  shadowRadius: CGFloat? = .none,
  shadowOffset: CGSize = .zero,
  // Item offset.
  offset: CGFloat = 0,
  // Bar offset.
  x: CGFloat = 0, y: CGFloat = 0,
  transition: AnyTransition = .identity,
  animation: Animation? = .none,
  @Builder content:
  @escaping (_ selected: Bool, _ state: Control.State) -> TabBarContent
 ) {
  self.init(
   tag: tag,
   height: height,
   inset: inset,
   padding: padding,
   bottomPadding: bottomPadding,
   spacing: spacing,
   style: style ?? .chrome,
   corners: corners,
   cornerRadius: cornerRadius,
   outlineColor: outlineColor ?? .outline.faded,
   shadowColor: shadowColor ?? .shadow.faint,
   shadowRadius: shadowRadius ?? 4.5,
   shadowOffset: shadowOffset,
   offset: offset,
   x: x, y: y,
   transition: transition,
   animation: animation,
   content: content
  )
 }
}

// MARK: Buildables
public struct TabBarView: View, Hashable {
 public static func == (lhs: TabBarView, rhs: TabBarView) -> Bool {
  lhs.hashValue == rhs.hashValue
 }

 public func hash(into hasher: inout Hasher) { hasher.combine(tag) }
 internal init(tag: AnyHashable? = .none, any view: AnyView) {
  self.tag = tag
  self.view = view
 }

 public init<V: View>(_ tag: AnyHashable? = .none, _ view: V) {
  if let view = view as? Self {
   self = view
   self.tag = tag
  } else {
   self.init(tag: tag, any: AnyView(view))
  }
 }

 var tag: AnyHashable?
 let view: AnyView
 public var body: some View { view }
}

public struct TabBarItem: View, Hashable {
 public static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
  lhs.hashValue == rhs.hashValue
 }

 public func hash(into hasher: inout Hasher) { hasher.combine(tag) }
 internal init(
  tag: AnyHashable? = .none, any view: AnyView, perform: (() -> ())? = .none
 ) {
  self.tag = tag
  self.view = view
  self.perform = perform
 }

 public init<V: View>(
  _ tag: AnyHashable? = .none,
  _ view: V, onHighlight perform: (() -> ())? = .none
 ) {
  if let view = view as? Self {
   self = view
   self.tag = tag
  } else {
   self.init(tag: tag, any: AnyView(view), perform: perform)
  }
 }

 public static func
  `default`(
   tag: AnyHashable? = .none,
   symbol: String,
   name: String? = .none,
   indicator: Bool = false,
   aspectRatio: CGFloat? = 1,
   width: CGFloat? = .none,
   height: CGFloat? = .none,
   onHighlight perform: (() -> ())? = .none
  ) -> Self {
  Self(
   tag,
   VerticalContent(spacing: 4.5) {
    Image(
     systemName: symbol
    ).resizable()
     .aspectRatio(aspectRatio, contentMode: .fit)
     .semibold()
     //.fixedFrame(20, alignment: .center)
     .frame(width: width ?? 20, height: height ?? 20, alignment: .center)
     .minimumScaleFactor(0.85)
     |>
     Text.Optional(name?.wrapped).bold(.caption2)
     .lineLimit(1)
     .minimumScaleFactor(0.85)
     .overlay(.leading) {
      if indicator {
       Circle()
        .frame(width: 8, height: 8)
        .accent()
        .offset(x: -11.5)
      }
     }
   },
   onHighlight: perform
  )
 }

 @_transparent
 public static func custom<V: View>(
  tag: AnyHashable? = .none,
  _ view: V, onHighlight perform: (() -> ())? = .none
 ) -> Self {
  Self(tag, view, onHighlight: perform)
 }

 var tag: AnyHashable?
 let view: AnyView
 var perform: (() -> ())?

 public var body: some View { view }
}

public extension TabBar {
 // MARK: Builder -
 @resultBuilder
 enum Builder {}
}

public typealias TabBarPair = (AnyView, TabBarItem)
public typealias TabBarContent = [TabBarPair]

public extension TabBar.Builder {
 static func buildBlock(_ pairs: TabBarPair...) -> TabBarContent {
  pairs.enumerated().map { offset, pair in
   (AnyView(pair.0.tag(offset)), pair.1)
  }
 }
}

// public extension TabBar.Builder
// where Tag: RawRepresentable, Tag.RawValue == Int {
// static func buildBlock(_ pairs: TabBarPair...) -> TabBarContent {
//  let count = pairs.count
//  TabBarStorage.shared.tags = .init(repeating: -1, count: count)
//  TabBarStorage.shared.views = .init(repeating: TabBarView(-1, EmptyView()), count: count)
//  return
//   pairs.enumerated().compactMap { offset, element in
//    guard let tag = (element.1.tag?.base as? Tag) ?? Tag(rawValue: offset) else {
//     fatalError("Raw value `\(offset)` not covered by `\(Tag.self)`")
//    }
//    TabBarStorage.shared.tags[offset] = AnyHashable(tag)
//    TabBarStorage.shared.views[offset] = TabBarView(tag, element.0.tag(tag))
//    return TabBarItem(tag, element.1.tag(tag))
//   }
// }
// }

final class TabBarStorage: ObservableObject {
 static let shared = TabBarStorage()
 var content: TabBarContent = .empty
 var usedTags: Set<Int> = .empty
 var lastTag: Int?
}

infix operator &>

public extension View {
 static func &> (lhs: Self, rhs: TabBarItem) -> (AnyView, TabBarItem) {
  (AnyView(lhs), rhs)
 }

 static func &> <A: View>(lhs: Self, rhs: A) -> (AnyView, TabBarItem) {
  (AnyView(lhs), .custom(rhs))
 }
}
