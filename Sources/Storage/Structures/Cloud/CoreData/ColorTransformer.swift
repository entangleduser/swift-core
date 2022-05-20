import SwiftUI
#if os(macOS)
 typealias ColorType = NSColor
#elseif os(iOS)
 typealias ColorType = UIColor
#endif

@available(macOS 10.14, iOS 12.0, *)
@objc(ColorTransformer)
public final class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
 public static let name =
  NSValueTransformerName(
   rawValue:
   String(
    describing: ColorTransformer.self
   )
  )
 override public static var allowedTopLevelClasses: [AnyClass] {
  [ColorType.self]
 }

 public static func register() {
  let transformer = ColorTransformer()
  ValueTransformer.setValueTransformer(transformer, forName: name)
 }
}
