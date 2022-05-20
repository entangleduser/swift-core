import SwiftUI
import Core
import Views

infix operator <->
infix operator <~>

public struct SwizzlePair: CustomStringConvertible {
 let old: Selector
 let new: Selector
 var `static` = false
 var `operator`: String {
  `static` ? "<~>" : "<->"
 }
 public var description: String {
  "\(old) \(self.operator) \(new)"
 }
}

public extension Selector {
 static func <-> (lhs: Selector, rhs: Selector) -> SwizzlePair {
  SwizzlePair(old: lhs, new: rhs)
 }

 static func <-> (lhs: Selector, rhs: String) -> SwizzlePair {
  SwizzlePair(old: lhs, new: Selector(rhs))
 }

 static func <~> (lhs: Selector, rhs: Selector) -> SwizzlePair {
  SwizzlePair(old: lhs, new: rhs, static: true)
 }

 static func <~> (lhs: Selector, rhs: String) -> SwizzlePair {
  SwizzlePair(old: lhs, new: Selector(rhs), static: true)
 }
}

public extension String {
 static func <-> (lhs: String, rhs: Selector) -> SwizzlePair {
  SwizzlePair(old: Selector(lhs), new: rhs)
 }

 static func <~> (lhs: String, rhs: Selector) -> SwizzlePair {
  SwizzlePair(old: Selector(lhs), new: rhs, static: true)
 }
}

public struct Swizzle {
 @resultBuilder
 public enum Builder {
  public static func buildBlock(
   _ swizzlePairs: SwizzlePair...
  ) -> [SwizzlePair] {
   Array(swizzlePairs)
  }
 }

 @discardableResult
 public init<T>(
  _ type: T.Type,
  @Builder _ makeSwizzlePairs: (T.Type) -> [SwizzlePair]
 ) throws where T: AnyObject {
  guard object_isClass(type) else {
   throw Error.missingClass(String(describing: type))
  }
  try swizzle(type: type, pairs: makeSwizzlePairs(type))
 }

 @discardableResult
 public init(
  _ string: String,
  @Builder _ makeSwizzlePairs: () -> [SwizzlePair]
 ) throws {
  guard let type = NSClassFromString(string) else {
   throw Error.missingClass(string)
  }
  let swizzlePairs = makeSwizzlePairs()
  try swizzle(type: type, pairs: swizzlePairs)
 }

 private func swizzle(
  type: AnyObject.Type,
  pairs: [SwizzlePair]
 ) throws {
  try pairs.forEach { pair in
   guard let `class` =
    pair.static ?
    object_getClass(type) : type
   else {
    throw Error.missingClass(type.description())
   }
   guard
    let lhs =
    class_getInstanceMethod(`class`, pair.old) else {
    throw Error.missingMethod(`class`, pair.static, true, pair)
   }
   guard let rhs =
    class_getInstanceMethod(`class`, pair.new) else {
    throw Error.missingMethod(`class`, pair.static, false, pair)
   }

   if pair.static,
      class_addMethod(
       `class`, pair.old,
       method_getImplementation(rhs), method_getTypeEncoding(rhs)
      ) {
    class_replaceMethod(
     `class`,
     pair.new,
     method_getImplementation(lhs),
     method_getTypeEncoding(lhs)
    )
   } else {
    method_exchangeImplementations(lhs, rhs)
   }
   debugPrint("Swizzled\(pair.static ? " static" : .empty) method for: \(pair)")
  }
 }
}

extension Swizzle {
 enum Error: LocalizedError {
  static let prefix: String = "Swizzle.Error: "
  case missingClass(_ name: String),
       missingMethod(
        _ type: AnyObject.Type, _ static: Bool, _ old: Bool, SwizzlePair
       )
  var failureReason: String? {
   switch self {
   case let .missingClass(type):
    return "Missing class: \(type)"
   case let .missingMethod(type, `static`, old, pair):
    return
     """
     Missing \(old ? "old" : "new")\(`static` ? " static" : .empty) method for \
     \(type.description()): \(pair)
     """
   }
  }
//  var recoverySuggestion: String? {
//   switch self {
//   case let .missingClass:
//    return ""
//   case let .missingMethod(type, `static`, old, pair):
//    return
//     """
//     Create \(old ? "old" : "new")\(`static` ? " static" : .empty) method for \
//     \(type.description()): \(pair)
//     """
//   }
//  }

  var errorDescription: String? {
   switch self {
   case .missingClass:
    return Self.prefix.appending(failureReason!)
   case .missingMethod:
    return Self.prefix.appending(failureReason!)
   }
  }
 }
}

struct SwizzleModifier<T: AnyObject>: ViewModifier {
 init(
  shouldSwizzle: Binding<Bool>,
  perform: (() -> ())?,
  pairs: @escaping (T.Type) -> [SwizzlePair]
 ) {
  _shouldSwizzle = shouldSwizzle
  self.perform = perform
  self.pairs = pairs
 }
 @Binding var shouldSwizzle: Bool {
  didSet {
   if oldValue != shouldSwizzle, shouldSwizzle { attempt() }
  }
 }
 let perform: (() -> ())?
 let pairs: (T.Type) -> [SwizzlePair]
 func attempt() {
  guard shouldSwizzle else { return }
  DispatchQueue.main.async {
   do {
    try Swizzle(T.self, pairs)
    perform?()
    shouldSwizzle = false
   } catch {
    debugPrint(error.message)
   }
  }
 }
 public func body(content: Content) -> some View {
  content.onAppear { attempt() }
 }
}

public extension View {
 @ViewBuilder func swizzle<T>(
  _ shouldSwizzle: Binding<Bool> = .constant(true),
 onSwizzle perform: (() -> ())? = .none,
  _ class: T.Type,
  @Swizzle.Builder pairs: @escaping (T.Type) -> [SwizzlePair]
 ) -> some View where T: AnyObject {
  modifier(
   SwizzleModifier<T>(
    shouldSwizzle: shouldSwizzle, perform: perform, pairs: pairs
   )
  )
 }
 @ViewBuilder func swizzle<T>(
 _ shouldSwizzle: Bool = true,
 onSwizzle perform: (() -> ())? = .none,
 _ class: T.Type,
 @Swizzle.Builder pairs: @escaping (T.Type) -> [SwizzlePair]
 ) -> some View where T: AnyObject {
  swizzle(.constant(shouldSwizzle), onSwizzle: perform, `class`, pairs: pairs)
 }
}
