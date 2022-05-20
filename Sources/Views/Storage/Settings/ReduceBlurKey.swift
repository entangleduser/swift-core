import SwiftUI
import Storage

public struct ReduceBlurKey: SettingsKey {
 public typealias Value = Bool
 public init() {}
}

public extension Settings {
 var reducedBlur: Bool! {
  get { self[ReduceBlurKey.self] }
  set { self[ReduceBlurKey.self] = newValue }
 }
}

public struct ReducedBlurEnvironmentKey: EnvironmentKey {
 public static let defaultValue: Bool? = .none
 public init() {}
}

public extension EnvironmentValues {
 var reducedBlur: Bool? {
  get { self[ReducedBlurEnvironmentKey.self] }
  set { self[ReducedBlurEnvironmentKey.self] = newValue }
 }
}

struct BlurModifier: ViewModifier {
 @Environment(\.reducedBlur) var reducedBlur
 @ObservedObject private var settings: Settings = .default
 let style: UIBlurEffect.Style
 let vibrancy: UIVibrancyEffectStyle?
 let disabled: Bool?
 @ViewBuilder func body(content: Content) -> some View {
  let content = content
  if disabled ?? reducedBlur ?? settings.reducedBlur {
   content
  } else {
   VisualEffectBlur(
    blurStyle: style,
    vibrancyStyle: vibrancy,
    content: { content }
   )
  }
 }
}

public extension View {
 #if os(iOS)
  @ViewBuilder func blurEffect(
   _ style: UIBlurEffect.Style = .regular,
   vibrancy: UIVibrancyEffectStyle? = .none,
   disabled: Bool? = .none
  ) -> some View {
   modifier(
    BlurModifier(style: style, vibrancy: vibrancy, disabled: disabled)
   )
  }
 #endif
}
