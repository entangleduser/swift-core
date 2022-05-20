import SwiftUI
import GameController

open class KeyboardManager: NSObject, ObservableObject {
 public static let shared = KeyboardManager()
 @Published public var keyboardConnected: Bool = GCKeyboard.coalesced != nil
 @Published public var keyboardVisible: Bool = false
 @Published public var keyboardFrame: CGRect = .zero
 @Published public var keyboardToolbarHeight: CGFloat = 0
 @Published public var keyboardAnimationCurve: UIView.AnimationCurve = .easeIn
 @Published public var keyboardAnimationDuration: Double = 0
 public var keyboardAnimation: Animation {
  switch keyboardAnimationCurve {
  case .easeIn: return .easeIn(duration: keyboardAnimationDuration)
  case .easeOut: return .easeOut(duration: keyboardAnimationDuration)
  case .linear: return .linear(duration: keyboardAnimationDuration)
  case .easeInOut: return .easeInOut(duration: keyboardAnimationDuration)
  @unknown default:
   fatalError()
  }
 }
 public var totalKeyboardFrame: CGRect {
  .init(
   x: keyboardFrame.origin.x,
   y: keyboardFrame.origin.y,
   width: keyboardFrame.width,
   height: keyboardFrame.height
  )
 }

 @objc func keyboardDidConnect() {
  keyboardConnected = true
 }

 @objc func keyboardDidDisconnect() {
  keyboardConnected = false
 }

 @objc func keyboardWillHide() {
  //keyboardFrame = .zero
  keyboardVisible = false
 }

 @objc func keyboardWillShow(_ notification: NSNotification) {
//  if let info = notification.userInfo {
//   if let frame: CGRect =
//    (info[
//     UIResponder.keyboardFrameEndUserInfoKey
//    ] as? NSValue)?.cgRectValue,
//    let window = UIWindow.key,
//    let view = window.rootViewController?.view {
//    keyboardFrame = view.convert(frame, to: window)
//    keyboardToolbarHeight =
//     keyboardFrame.minY - keyboardFrame.height
//   } else {
//    keyboardFrame = .zero
//   }
//   if let curveValue =
//    (info[UIResponder.keyboardAnimationCurveUserInfoKey]
//     as? NSNumber)?.intValue,
//    let curve =
//       UIView.AnimationCurve(rawValue: curveValue),
//    let duration = (info[
//     UIResponder.keyboardAnimationDurationUserInfoKey
//    ] as? NSNumber)?.doubleValue {
//    keyboardAnimationCurve = curve
//     keyboardAnimationDuration = duration
//   }
//  }
  keyboardVisible = true
 }

 deinit {
  NotificationCenter.default.removeObserver(self)
 }

 override public init() {
  super.init()
  NotificationCenter.default.addObserver(
   self,
   selector: #selector(keyboardWillHide),
   name: UIResponder.keyboardWillHideNotification, object: nil
  )
  NotificationCenter.default.addObserver(
   self,
   selector: #selector(keyboardDidConnect),
   name: .GCKeyboardDidConnect, object: nil
  )
  NotificationCenter.default.addObserver(
   self,
   selector: #selector(keyboardDidDisconnect),
   name: .GCKeyboardDidDisconnect, object: nil
  )
  NotificationCenter.default.addObserver(
   self,
   selector: #selector(keyboardWillShow),
   name: UIResponder.keyboardWillShowNotification,
   object: nil
  )
 }
}

public struct KeyboardConnectedKey: EnvironmentKey {
 public static let defaultValue = KeyboardManager.shared.keyboardConnected
 public init() {}
}

public struct KeyboardVisibleKey: EnvironmentKey {
 public static let defaultValue = KeyboardManager.shared.keyboardVisible
 public init() {}
}

public extension EnvironmentValues {
 var keyboardConnected: Bool {
  self[KeyboardConnectedKey.self]
 }

 var keyboardVisible: Bool {
  self[KeyboardVisibleKey.self]
 }
}
