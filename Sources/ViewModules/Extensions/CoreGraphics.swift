#if os(macOS)
 import AppKit
 typealias Screen = NSScreen
#elseif os(iOS)
 import UIKit
 typealias Screen = UIScreen
 public extension UIWindow {
  static let key: UIWindow? =
//  UIApplication.shared.connectedScenes.first(where: { $0. )
//    .filter({ $0.activationState == .foregroundActive })
//    .compactMap({ $0 as? UIWindowScene })
//    .first?.windows
//    .filter(\.isKeyWindow).first ??
   UIApplication.shared.windows.first(where: \.isKeyWindow)
 }

 public extension UIEdgeInsets {
  static var screen: UIEdgeInsets {
   guard let window: UIWindow = .key else { fatalError() }
   return window.safeAreaInsets
  }
 }

 public extension CGFloat {
  static let insets: UIEdgeInsets = .screen
 }
#endif

public extension CGSize {
 var rect: CGRect { .init(x: 0, y: 0, width: width, height: height) }
}
public extension CGRect {
 #if os(iOS)
 static let screen: CGRect = UIScreen.main.bounds
 //{ UIWindow.key?.rootViewController?.view?.bounds ?? .zero }()
 func convertToScreen() -> CGRect {
  guard let window = UIWindow.key,
        let view = window.rootViewController?.view
  else { return .zero }
  return view.convert(self, to: window)
 }
 #elseif os(macOS)
 static let screen: CGRect = Screen.main!.frame
 //{ UIWindow.key?.rootViewController?.view?.bounds ?? .zero }()
 //Screen.main?.frame ?? UIWindow.key?.screen
 #endif
}

public extension CGFloat {
 static let screen: CGRect = .screen
}
