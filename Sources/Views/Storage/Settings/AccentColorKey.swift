import SwiftUI
import Storage
import Colors

extension Color {
 public static var defaultColor: Self {
  Settings.default.accentColor
 }
}

extension ColorCodable {
 public static var defaultColor: Self {
  Self(Color.defaultColor)
 }
}

@available(iOS 15.0, *)
extension UIColor {
 @objc public class var _tintColor: UIColor { tintColor }
}

public extension UIColor {
 class var defaultColor: UIColor {
  UIColor(Settings.default.accentColor)
 }
 @objc class var _defaultColor: UIColor { defaultColor }
}

public struct AccentColorKey: SettingsKey {
 public static let defaultValue: Color = .accent
 public init() {}
}

public extension Settings {
 var accentColor: Color! {
  get { self[codable: AccentColorKey.self] }
  set { self[codable: AccentColorKey.self] = newValue }
 }
}

