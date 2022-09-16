import SwiftUI

public protocol PairedView: View {
 associatedtype Primary: View
 associatedtype Secondary: View
 var content: Primary? { get set }
 var secondaryContent: Secondary? { get set }
 /// Primary content position.
 var position: Position! { get set }
 /// Primary content anchor.
 // TODO: Possibly remove if it doesn't help horizontal views (helps positional).
 var anchor: Position! { get set }
 var spacing: CGFloat? { get set }
 var alignment: Alignment! { get set }
 var padding: CGFloat { get set }
 init()
 init(
  content: Primary?,
  secondaryContent: Secondary?,
  position: Position!,
  anchor: Position!,
  spacing: CGFloat?, alignment: Alignment!, padding: CGFloat
 )
}

public extension PairedView {
 /// The convenience initializer.
 init(
  content: Primary? = .none,
  secondaryContent: Secondary? = .none,
  position: Position! = .none,
  anchor: Position! = .none,
  spacing: CGFloat? = .none,
  alignment: Alignment! = .none,
  padding: CGFloat = 0
 ) {
  self.init()
  self.content = content
  self.secondaryContent = secondaryContent
  self.position = position
  self.anchor = anchor
  self.spacing = spacing
  self.alignment = alignment
  self.padding = padding
 }

 init(
  _ alignment: Alignment! = .none,
  position: Position! = .none,
  anchor: Position! = .none,
  spacing: CGFloat? = .none,
  padding: CGFloat = 0,
  content: @escaping () -> (Primary, Secondary)
 ) {
  let content = content()
  self.init(
   content: content.0,
   secondaryContent: content.1,
   position: position,
   anchor: anchor,
   spacing: spacing,
   alignment: alignment,
   padding: padding
  )
 }
}

public struct VerticalContent<A: View, B: View>: PairedView {
 public init() {}
 public init(
  _ content: A? = .none,
  secondary: B? = .none,
  position: Position? = .top,
  anchor: Position? = .left,
  spacing: CGFloat? = .none,
  alignment: Alignment! = .center,
  padding: CGFloat = 0
 ) {
  self.init(
   content: content,
   secondaryContent: secondary,
   position: position,
   anchor: anchor,
   spacing: spacing,
   alignment: alignment,
   padding: padding
  )
 }

 public var content: A? = .none,
            secondaryContent: B? = .none,
            position: Position! = .top,
            anchor: Position! = .left,
            spacing: CGFloat? = .none,
            alignment: Alignment! = .center,
            padding: CGFloat = 0
 var adjustedAlignment: Alignment { alignment ?? .center }
 var adjustedPosition: Position { position ?? .top }
 var adjustedAnchor: Position { anchor ?? .left }
 public var body: some View {
  VStack(alignment: adjustedAlignment.horizontal, spacing: spacing) {
   Group {
    if adjustedPosition == .center {
     HorizontalContent(
      content: content,
      secondaryContent: secondaryContent,
      position: adjustedAnchor,
      spacing: spacing,
      alignment: adjustedAnchor.alignment,
      padding: padding
     )
    } else {
     if adjustedPosition == .top { content }
     secondaryContent
     if adjustedPosition == .bottom { content }
    }
   }
   .padding(.vertical, padding)
  }
 }
}

/// - Note: Could be the convience wrapper for `SwiftUI.Label` and positional
/// toolbar content.
public struct HorizontalContent<A: View, B: View>: PairedView {
 public init() {}
 public init(
  _ content: A? = .none,
  secondary: B? = .none,
  position: Position? = .left,
  anchor: Position? = .none,
  spacing: CGFloat? = .none,
  alignment: Alignment! = .leading,
  padding: CGFloat = 0
 ) {
  self.init(
   content: content,
   secondaryContent: secondary,
   position: position,
   anchor: anchor,
   spacing: spacing,
   alignment: alignment,
   padding: padding
  )
 }

 public var content: A? = .none,
            secondaryContent: B? = .none,
            position: Position! = .left,
            anchor: Position! = .none,
            spacing: CGFloat? = .none,
            alignment: Alignment! = .leading,
            padding: CGFloat = 0
 var adjustedAlignment: Alignment { alignment ?? .leading }
 var adjustedPosition: Position { position ?? .left }
 public var body: some View {
  HStack(alignment: adjustedAlignment.vertical, spacing: spacing) {
   Group {
    if adjustedPosition == .left { content }
    secondaryContent
    if adjustedPosition == .right { content }
   }
   .padding(.horizontal, padding)
  }
 }
}

public struct PositionalContent<A: View, B: View>: PairedView {
 public init() {}
 public init(
  _ content: A? = .none,
  secondary: B? = .none,
  position: Position? = .none,
  anchor: Position? = .left,
  spacing: CGFloat? = .none,
  alignment: Alignment! = .none,
  padding: CGFloat = 0
 ) {
  self.init(
   content: content,
   secondaryContent: secondary,
   position: position,
   anchor: anchor,
   spacing: spacing,
   alignment: alignment,
   padding: padding
  )
 }

 public var content: A? = .none,
            secondaryContent: B? = .none,
            position: Position! = .none,
            anchor: Position! = .left,
            spacing: CGFloat? = .none,
            alignment: Alignment! = .none,
            padding: CGFloat = 0
 public var body: some View {
  if position.isVertical {
   VerticalContent(
    content: content,
    secondaryContent: secondaryContent,
    position: position,
    anchor: anchor, spacing: spacing, alignment: alignment, padding: padding
   )
  } else {
   HorizontalContent(
    content: content,
    secondaryContent: secondaryContent,
    position: position,
    spacing: spacing, alignment: alignment, padding: padding
   )
  }
 }
}


// extension ViewPair where A == AnyView, B == IndexedView {
// init<V0: View, V1: View>(_ first: V0, _ second: V1) {
//  self.init(AnyView(first), IndexedView(second))
// }
//
// init<V0: View, V1: View>(_ tuple: (V0, V1)) {
//  self.init(tuple.0, tuple.1)
// }
// }

// Typed
infix operator |>

public extension View {
 static func |> <A: View>(lhs: Self, rhs: A) -> (Self, A) { (lhs, rhs) }

 static func |> <A: View>(
  lhs: Self,
  @ViewBuilder rhs: () -> A
 ) -> (Self, A) { (lhs, rhs()) }
}




//public typealias AnyViewPairs = [AnyViewPair]
//@resultBuilder
//public enum PairBuilder {
// public static func buildArray<A: View, B: View>(
//  _ pairs: AnyViewPair...
// ) -> AnyViewPairs { pairs }
//}
// public static func buildBlock(
//  _ pairs: AnyViewPair...
// ) -> ViewPairs {
//  pairs
// }
//
// public static func buildArray(_ pairs: IndexedViewPairs) -> IndexedViewPairs {
//  pairs.enumerated().map {
//   IndexedViewPair(
//    $0.element.primary,
//    $0.element.secondary.environment(\.index, $0.offset)
//   )
//  }
// }
// public static func buildBlock<V: View, T: View>(
//  _ pair: (V, T)
// ) -> ViewPairs { [ViewPair(pair)] }
// public static func buildBlock<V0, T0, V1, T1>(
//  _ p0: (V0, T0), _ p1: (V1, T1)
// ) -> ViewPairs
// where V0: View, T0: View, V1: View, T1: View {
//  [ViewPair(p0), ViewPair(p1)]
// }
//
// public static func buildBlock<V0, T0, V1, T1, V2, T2>(
//  _ p0: (V0, T0), _ p1: (V1, T1), _ p2: (V2, T2)
// ) -> ViewPairs
// where V0: View, T0: View, V1: View, T1: View, V2: View, T2: View {
//  [ViewPair(p0), ViewPair(p1), ViewPair(p2)]
// }
//}

// public struct ContentPairs<ID: Hashable> {
// public var data: [ID: ViewPair<AnyView, AnyView>] = .empty
// subscript(primary tag: ID) -> AnyView? { data[tag]?.tuple.0 }
// subscript(secondary tag: ID) -> AnyView? { data[tag]?.tuple.1 }
// init<V: View, T: View>(_ tag: ID, _ pair: (V, T)) {
//  data[tag] = ViewPair(pair)
// }
//
// init<V0, T0, V1, T1>(
//  _ t1: ID, _ p0: (V0, T0),
//  _ t0: ID, _ p1: (V1, T1)
// ) where V0: View, T0: View, V1: View, T1: View {
//  data[t0] = ViewPair(p0)
//  data[t1] = ViewPair(p1)
// }
//
// init<V0, T0, V1, T1, V2, T2>(
//  _ t0: ID, _ p0: (V0, T0),
//  _ t1: ID, _ p1: (V1, T1),
//  _ t2: ID, _ p2: (V2, T2)
// ) where V0: View, T0: View, V1: View, T1: View, V2: View, T2: View {
//  data[t0] = ViewPair(p0)
//  data[t1] = ViewPair(p1)
//  data[t2] = ViewPair(p2)
// }
// // TODO: Support non `Int` tags.
// }
//
// extension ContentPairs where ID: BinaryInteger {
// init<V: View, T: View>(_ pair: (V, T)) {
//  self.init(0, pair)
// }
//
// init<V0, T0, V1, T1>(
//  _ p0: (V0, T0), _ p1: (V1, T1)
// ) where V0: View, T0: View, V1: View, T1: View {
//  self.init(0, p0, 1, p1)
// }
//
// init<V0, T0, V1, T1, V2, T2>(
//  _ p0: (V0, T0),
//  _ p1: (V1, T1),
//  _ p2: (V2, T2)
// )
//  where V0: View, T0: View, V1: View, T1: View, V2: View, T2: View {
//  self.init(0, p0, 1, p1, 2, p2)
// }
// }
