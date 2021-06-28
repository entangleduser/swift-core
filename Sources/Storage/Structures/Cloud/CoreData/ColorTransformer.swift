import SwiftUI
//import Core.Color
#if os(macOS)
  typealias NativeColor = NSColor
#elseif os(iOS)
  typealias NativeColor = UIColor
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
    [NativeColor.self]
  }

  public static func register() {
    let transformer = ColorTransformer()
    ValueTransformer.setValueTransformer(transformer, forName: name)
  }
}
