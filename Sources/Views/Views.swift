import Colors
import Storage
import SwiftUI
import Core

#if os(iOS)
public typealias NativeColor = Colors.NativeColor
 public typealias NativeImage = UIImage
 public typealias NativeEdgeInsets = UIEdgeInsets
#elseif os(macOS)
 public typealias NativeImage = NSImage
 public typealias NativeEdgeInsets = NSEdgeInsets
#endif

// MARK: Structures -
/// A static position option.
public enum Position: UInt8, Equatable {
 case center, top, bottom, left, right
 public var alignment: Alignment {
  switch self {
  case .center: return .center
  case .top: return .top
  case .bottom: return .bottom
  case .left: return .leading
  case .right: return .trailing
  }
 }

 public var isVertical: Bool {
  ![Self.left, .right].contains(self)
 }

 public var isHorizontal: Bool {
  !isVertical
 }

 public var edges: Edge.Set {
  switch self {
  case .center: return .all
  case .top: return .top
  case .bottom: return .bottom
  case .left: return .leading
  case .right: return .trailing
  }
 }

 public var balance: Edge.Set {
  isVertical ? .vertical : .horizontal
 }

 public var offset: Self {
  isVertical ?
   self == .top ? .bottom : .top :
   self == .left ? .left : .right
 }
}

public struct CornerSet: OptionSet, Sequence {
 public let rawValue: Int
 public static let none: Self = .empty
 public static let bottomLeft: Self = .init(rawValue: 1 << 1)
 public static let bottomRight: Self = .init(rawValue: 1 << 2)
 public static let topLeft: Self = .init(rawValue: 1 << 3)
 public static let topRight: Self = .init(rawValue: 1 << 4)
 public static let top: Self = [.topLeft, .topRight]
 public static let bottom: Self = [.bottomLeft, .bottomRight]
 public static let left: Self = [.bottomLeft, .topLeft]
 public static let right: Self = [.bottomRight, .topRight]
 public static let all: Self = [.top, .bottom]
 public init(rawValue: Int) { self.rawValue = rawValue }
}

// extension CornerSet: Sequence {}
// MARK: Extensions -
extension Color: JSONCodable {
 public init() { self = .clear }
}
extension Edge.Set: Sequence {}

public extension Edge.Set {
 static let topTrailing: Self = [.top, .trailing]
 static let topLeading: Self = [.top, .leading]
 static let bottomTrailing: Self = [.bottom, .trailing]
 static let bottomLeading: Self = [.bottom, .leading]
}

extension Path {
 init(rect: CGRect, corners: CornerSet, radius: CGFloat) {
  #if os(iOS)
   let cgPath =
    BezierPath(
     roundedRect: rect,
     byRoundingCorners: corners.uiCorner,
     cornerRadii: CGSize(width: radius, height: radius)
    ).cgPath
  #elseif os(macOS)
   let cgPath =
    CGPath(
     roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil
    )
  #endif
  self = Path(cgPath)
 }
}

#if os(iOS)
 public typealias BezierPath = UIBezierPath
 extension CornerSet {
  var uiCorner: UIRectCorner {
   switch self {
   case .none: return .empty
   case .all: return .allCorners
   case .top: return [.topLeft, .topRight]
   case .bottom: return [.bottomLeft, .bottomRight]
   case .left: return [.bottomLeft, .topLeft]
   case .right: return [.bottomRight, .topRight]
   case .bottomLeft: return .bottomLeft
   case .bottomRight: return .bottomRight
   case .topLeft: return .topLeft
   case .topRight: return .topRight
   default: return .empty
   }
  }
 }

#elseif os(macOS)
 typealias BezierPath = NSBezierPath
#endif

extension EdgeInsets: ExpressibleAsZero {
 public static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
 public static let device: EdgeInsets = CGFloat.insets.edgeInsets
 mutating func add(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) {
  for edge in edges {
   switch edge {
    case .top: top = top + offset
    case .bottom: bottom = bottom + offset
    case .leading: leading = leading + offset
    case .trailing: leading = trailing + offset
    default: break
   }
  }
 }
 public func adding(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) -> Self {
  var copy = self
  copy.add(edges, offset)
  return copy
 }
 public static func additional(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) -> EdgeInsets {
  EdgeInsets(
   top: edges.contains(.top) ? offset : 0,
   leading: edges.contains(.leading) ? offset : 0,
   bottom: edges.contains(.bottom) ? offset : 0,
   trailing: edges.contains(.trailing) ? offset : 0
  )
 }

 public static func system(_ edges: Edge.Set = .all, _: CGFloat) -> EdgeInsets {
  EdgeInsets(
   top: edges.contains(.top) ? 0 : .insets.top,
   leading: edges.contains(.leading) ? 0 : .insets.left,
   bottom: edges.contains(.bottom) ? 0 : .insets.bottom,
   trailing: edges.contains(.trailing) ? 0 : .insets.right
  )
 }

 public init(_ edges: Edge.Set = .all, _ offset: CGFloat) {
  self.init()
  for edge in edges {
   switch edge {
   case .top: top = offset
   case .bottom: bottom = offset
   case .leading: leading = offset
   case .trailing: trailing = offset
   default: break
   }
  }
 }
}

extension NativeEdgeInsets: ExpressibleAsZero {
 public static let zero = NativeEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
 public static let device = CGFloat.insets
 mutating func add(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) {
  for edge in edges {
   switch edge {
    case .top: top = top + offset
    case .bottom: bottom = bottom + offset
    case .leading: left = left + offset
    case .trailing: right = right + offset
    default: break
   }
  }
 }
 public func adding(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) -> Self {
  var copy = self
  copy.add(edges, offset)
  return copy
 }
 public static func additional(
  _ edges: Edge.Set = .all, _ offset: CGFloat
 ) -> NativeEdgeInsets {
  NativeEdgeInsets(
   top: edges.contains(.top) ? offset : 0,
   left: edges.contains(.leading) ? offset : 0,
   bottom: edges.contains(.bottom) ? offset : 0,
   right: edges.contains(.trailing) ? offset : 0
  )
 }

 public static func system(_ edges: Edge.Set = .all, _: CGFloat) -> NativeEdgeInsets {
  NativeEdgeInsets(
   top: edges.contains(.top) ? 0 : .insets.top,
   left: edges.contains(.leading) ? 0 : .insets.left,
   bottom: edges.contains(.bottom) ? 0 : .insets.bottom,
   right: edges.contains(.trailing) ? 0 : .insets.right
  )
 }

 public var edgeInsets: EdgeInsets {
  EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
 }

 public init(_ edges: Edge.Set = .all, _ offset: CGFloat) {
  self.init()
  for edge in edges {
   switch edge {
   case .top: top = offset
   case .bottom: bottom = offset
   case .leading: left = offset
   case .trailing: right = offset
   default: break
   }
  }
 }
}

public extension CaseIterable
where AllCases.Element: Equatable {
 func next(
  with condition: ((AllCases.Element) -> Bool)? = .none
 ) -> AllCases.Element? {
  var cases = Self.allCases as! [Self]
  if let condition = condition { cases = Self.allCases.filter(condition) }
  if let initialIndex = cases.firstIndex(of: self) {
   let nextIndex = cases.index(initialIndex, offsetBy: 1)
   let finalIndex = nextIndex == cases.endIndex ? cases.startIndex : nextIndex
   return cases[finalIndex]
  }
  return cases.first
 }
 var next: AllCases.Element {
  next() ?? Self.allCases.first!
 }
}

// MARK: Convenience Functions
public func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
 .init(get: { lhs.wrappedValue ?? rhs }, set: { lhs.wrappedValue = $0 })
}

public extension EnvironmentKey where Value: Infallible {
 static var defaultValue: Value { .defaultValue }
}

public extension ViewModifier where Body == Content {
 func body(content: Content) -> Content { content }
}

public extension Animation {
 static let toast: Animation =
  .interactiveSpring(response: 0.2, dampingFraction: 0.75, blendDuration: 1)
 static let modal: Animation =
  .interactiveSpring(response: 0.2, dampingFraction: 0.675, blendDuration: 1)
 static let alert: Animation =
  .spring(response: 0.42, dampingFraction: 0.75, blendDuration: 0.75)
 static let interactive: Animation =
  .interactiveSpring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.5)
}

public extension Alignment {
 var text: TextAlignment {
  switch self {
  case .center: return .center
  case .trailing: return .trailing
  default: return .leading
  }
 }
}

extension Alert: Identifiable {
 public var id: UUID { nil }
}
